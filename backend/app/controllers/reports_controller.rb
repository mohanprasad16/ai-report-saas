class ReportsController < ApplicationController
  def create
    prompt = params[:prompt]

    client = GeminiClient.new
    response = client.generate(prompt)

    content = response["candidates"][0]["content"]["parts"][0]["text"]
    usage = response["usageMetadata"]

    report = AiReport.create!(
      prompt: prompt,
      response: content,
      model: response["modelVersion"],
      prompt_tokens: usage["promptTokenCount"],
      completion_tokens: usage["candidatesTokenCount"],
      total_tokens: usage["totalTokenCount"]
    )

    render json: {
      id: report.id,
      response: content
    }
  end
end
