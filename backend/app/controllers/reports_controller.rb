class ReportsController < ApplicationController
  def create
    prompt = params[:prompt]
    client = GeminiClient.new
    
    response = client.chat(
      prompt: prompt,
      tools: ReportingTools.definitions,
      system_instruction: SYSTEM_INSTRUCTION
    )

    if response["error"]
      render json: response, status: :bad_request
      return
    end

    final_text = extract_text(response)
    
    if final_text.blank?
      render json: { error: "No response generated" }, status: :unprocessable_entity
      return
    end

    save_report(prompt, final_text, response)
    render json: { analysis: final_text }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  SYSTEM_INSTRUCTION = <<~INSTRUCTION
    You are a specialized Finance Performance Agent.
    Your SOLE purpose is to answer business questions using the provided tools (Revenue, Marketing Spend, Churn).
    
    STRICT RULES:
    1. IF the user asks about Revenue, Marketing, or Churn -> Use the tools to fetch data and analyze it.
    2. IF the user asks for data you don't have -> Politely say "I do not have access to that data."
    3. IF the user asks general questions -> Politely say "I can only answer questions about finance performance."
    
    Process:
    1. Identify key metrics/periods.
    2. Fetch data via tools.
    3. Compare data (Current vs Previous).
    4. Provide structured, data-backed explanation.
  INSTRUCTION

  def extract_text(response)
    response.dig("candidates", 0, "content", "parts", 0, "text")
  end

  def save_report(prompt, text, response)
    usage = response["usageMetadata"] || {}
    AiReport.create!(
      prompt: prompt,
      response: { analysis: text }.to_json,
      model: response["modelVersion"] || "gemini-1.5-flash",
      prompt_tokens: usage["promptTokenCount"].to_i,
      completion_tokens: usage["candidatesTokenCount"].to_i,
      total_tokens: usage["totalTokenCount"].to_i
    )
  end
end