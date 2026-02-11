class GeminiClient
  include HTTParty
  base_uri "https://generativelanguage.googleapis.com/v1beta"

  DEFAULT_MODEL = "gemini-2.0-flash-lite"
  MAX_ITERATIONS = 5

  def initialize
    @api_key = ENV["GEMINI_API_KEY"]
  end

  def chat(prompt:, tools: nil, system_instruction: nil)
    # 1. Setup initial conversation state
    messages = [{ role: "user", parts: [{ text: prompt }] }]
    
    # 2. Build the initial API payload
    payload = {
      contents: messages,
      tools: tools,
      generation_config: { temperature: 0.2 }
    }
    
    if system_instruction
      payload[:system_instruction] = { parts: [{ text: system_instruction }] }
    end

    # 3. Enter the "Think -> Act -> Observe" Loop
    run_conversation_loop(payload)
  end

  def embed(text)
    response = self.class.post(
      "/models/gemini-embedding-001:embedContent?key=#{@api_key}",
      headers: { "Content-Type" => "application/json" },
      body: {
        model: "models/gemini-embedding-001",
        content: { parts: [{ text: text }] }
      }.to_json
    )

    unless response.success?
      raise "Gemini Embedding Error: #{response.code} - #{response.body}"
    end

    values = JSON.parse(response.body).dig("embedding", "values")
    puts "DEBUG: Embedding size: #{values.length}"
    values
  end

  private

  def run_conversation_loop(payload)
    iterations = 0

    loop do
      # A. Call Gemini API
      response = call_gemini_api(payload)
      return api_error(response) unless response.success?

      # B. Parse the Response
      parsed_body = JSON.parse(response.body)
      candidate = parsed_body.dig("candidates", 0)
      return { "error" => "No response candidate found" } unless candidate

      content = candidate["content"] # The message from the AI
      function_calls = extract_function_calls(content)

      # C. Decide: Answer User OR Execute Tools
      if function_calls.none?
        return parsed_body # Final Answer
      end

      # D. Handle Tool Execution
      return { "error" => "Too many tool steps" } if iterations >= MAX_ITERATIONS
      
      process_tool_calls(payload, content, function_calls)
      iterations += 1
    end
  end

  def call_gemini_api(payload)
    # Removing leading slash to append correctly to base_uri
    self.class.post(
      "/models/#{DEFAULT_MODEL}:generateContent?key=#{@api_key}",
      headers: { "Content-Type" => "application/json" },
      body: payload.compact.to_json
    )
  end

  def extract_function_calls(content)
    parts = content["parts"] || []
    parts.select { |part| part.key?("functionCall") }
  end

  def process_tool_calls(payload, model_message, function_calls)
    messages = payload[:contents]

    # 1. Add the AI's "Request" to history (so it remembers what it asked)
    messages << model_message

    # 2. Execute the requested tools
    tool_responses = function_calls.map do |call_part|
      execute_single_tool(call_part["functionCall"])
    end

    # 3. Add the Tool "Results" to history
    messages << { role: "function", parts: tool_responses }

    # 4. Update payload for the next loop iteration
    payload[:contents] = messages
  end

  def execute_single_tool(call_data)
    name = call_data["name"]
    args = call_data["args"] || {}

    # Run the actual Ruby code for the tool
    result = ReportingTools.execute(name, args)

    # Format result for Gemini API
    {
      functionResponse: {
        name: name,
        response: { name: name, content: result }
      }
    }
  end

  def api_error(response)
    { 
      "error" => "Gemini API Error: #{response.code}", 
      "details" => response.body 
    }
  end
end