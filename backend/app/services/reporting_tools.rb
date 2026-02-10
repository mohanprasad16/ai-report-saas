class ReportingTools
  def self.definitions
    [
      {
        "function_declarations": [
          {
            "name": "fetch_sales_data",
            "description": "Get the total revenue for a specific region and month.",
            "parameters": {
              "type": "OBJECT",
              "properties": {
                "region": { "type": "STRING", "description": "The region (e.g., 'EMEA', 'US', 'APAC')" },
                "month": { "type": "STRING", "description": "The month (e.g., 'May', 'April')" }
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
                "month": { "type": "STRING", "description": "The month (e.g., 'May', 'April')" }
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
                "month": { "type": "STRING", "description": "The month (e.g., 'May', 'April')" }
              },
              "required": ["region", "month"]
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

  private

  def parse_date(month_str)
    # For demo purposes, we assume 2024.
    Date.parse("#{month_str} 2024")
  rescue
    Date.current
  end
end