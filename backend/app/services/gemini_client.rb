# app/services/gemini_client.rb
class GeminiClient
  include HTTParty
  base_uri "https://generativelanguage.googleapis.com/v1"

  def generate(prompt)
    api_key = ENV["GEMINI_API_KEY"]

    body = {
      contents: [
                  {
                    parts: [
                             { text: prompt }
                           ]
                  }
                ]
    }

    self.class.post(
      "/models/gemini-2.5-flash-lite:generateContent?key=#{api_key}",
      headers: { "Content-Type" => "application/json" },
      body: body.to_json
    )
  end
end
