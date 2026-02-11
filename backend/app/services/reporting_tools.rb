class ReportingTools
  def self.definitions
    [
      {
        "functionDeclarations": [
          {
            "name": "fetch_sales_data",
            "description": "Get the total revenue for a specific region and month.",
            "parameters": {
              "type": "OBJECT",
              "properties": {
                "region": { "type": "STRING", "description": "The region (e.g., 'EMEA', 'US', 'APAC')" },
                "month": { "type": "STRING", "description": "The month and year (e.g., 'May 2024', 'April 2025')" }
              },
              "required": ["region", "month"]
            }
          },
          {
            "name": "fetch_marketing_spend",
            "description": "Get the marketing spend amount for a specific region and month.",
            "parameters": {
              "type": "OBJECT",
              "properties": {
                "region": { "type": "STRING", "description": "The region (e.g., 'EMEA', 'US', 'APAC')" },
                "month": { "type": "STRING", "description": "The month and year (e.g., 'May 2024', 'April 2025')" }
              },
              "required": ["region", "month"]
            }
          },
          {
            "name": "fetch_churn_data",
            "description": "Get the churn rate percentage for a specific region and month.",
            "parameters": {
              "type": "OBJECT",
              "properties": {
                "region": { "type": "STRING", "description": "The region (e.g., 'EMEA', 'US', 'APAC')" },
                "month": { "type": "STRING", "description": "The month and year (e.g., 'May 2024', 'April 2025')" }
              },
              "required": ["region", "month"]
            }
          },
          {
            "name": "search_internal_docs",
            "description": "Search internal knowledge base for qualitative info, business strategies, and reasons behind performance changes.",
            "parameters": {
              "type": "OBJECT",
              "properties": {
                "query": { "type": "STRING", "description": "The search query (e.g., 'reason for revenue drop')" }
              },
              "required": ["query"]
            }
          },
          {
            "name": "forecast_revenue",
            "description": "Predict next month's revenue based on historical trends.",
            "parameters": {
              "type": "OBJECT",
              "properties": {
                "region": { "type": "STRING", "description": "The region to forecast (e.g., 'EMEA', 'US', 'APAC')" }
              },
              "required": ["region"]
            }
          }
        ]
      }
    ]
  end

  def self.execute(name, args)
    new.send(name, **args.symbolize_keys)
  rescue NoMethodError
    { error: "Tool #{name} not found" }
  rescue ArgumentError => e
    { error: "Invalid arguments for #{name}: #{e.message}" }
  end

  def fetch_sales_data(region:, month:)
    date = parse_date(month)
    amount = Revenue.find_by(region: region, month: date)&.total_revenue || 0
    { revenue: amount, currency: "USD", region: region, month: month }
  end

  def fetch_marketing_spend(region:, month:)
    date = parse_date(month)
    amount = MarketingSpend.find_by(region: region, month: date)&.spend_amount || 0
    { spend: amount, currency: "USD", region: region, month: month }
  end

  def fetch_churn_data(region:, month:)
    date = parse_date(month)
    rate = ChurnMetric.find_by(region: region, month: date)&.churn_rate || 0.0
    { churn_rate: rate, unit: "percent", region: region, month: month }
  end

  def search_internal_docs(query:)
    # 1. Generate embedding for query
    embedding = GeminiClient.new.embed(query)
    
    # 2. Search nearest neighbors
    docs = KnowledgeBaseArticle.nearest_neighbors(:embedding, embedding, distance: "cosine").limit(3)
    
    # 3. Format results
    context = docs.map do |doc|
      "--- Document: #{doc.title} ---\n#{doc.content}"
    end.join("\n\n")

    context.present? ? { context: context } : { error: "No relevant documents found." }
  end

  def forecast_revenue(region:)
    # 1. Fetch last 3 months of data dynamically
    # Example: If today is Feb 2025, fetch Nov 2024, Dec 2024, Jan 2025
    today = Date.current
    months = (1..3).map { |i| today.prev_month(i).beginning_of_month }
    
    revenues = Revenue.where(region: region, month: months).order(:month).pluck(:total_revenue)

    if revenues.length < 2
      # Fallback to demo data if real data is missing (for the sake of the prototype)
      # In production, this would just return the error.
      months = ["March", "April", "May"].map { |m| Date.parse("#{m} 2024") }
      revenues = Revenue.where(region: region, month: months).order(:month).pluck(:total_revenue)
    end
    
    if revenues.length < 2
      return { error: "Not enough historical data to forecast." }
    end

    # 2. Simple Linear Forecast (y = mx + b)
    # Using indices 0, 1, 2 as x-values
    n = revenues.length
    sum_x = (0...n).sum
    sum_y = revenues.sum
    sum_xy = revenues.each_with_index.sum { |y, x| x * y }
    sum_xx = (0...n).sum { |x| x**2 }

    slope = (n * sum_xy - sum_x * sum_y).to_f / (n * sum_xx - sum_x**2)
    intercept = (sum_y - slope * sum_x) / n

    # 3. Predict next month (index 3)
    prediction = (slope * 3 + intercept).round(2)
    growth_rate = ((prediction - revenues.last) / revenues.last.to_f * 100).round(1)

    {
      predicted_revenue: prediction,
      confidence: "medium",
      method: "linear_regression",
      growth_trend: "#{growth_rate}%",
      historical_data: revenues
    }
  end

    private

  

    def parse_date(month_str)
      date = Date.parse(month_str)
      date
    rescue
      Date.current
    end

  end

  