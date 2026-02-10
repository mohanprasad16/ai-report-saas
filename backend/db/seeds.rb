# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding data..."

Revenue.destroy_all
ChurnMetric.destroy_all
MarketingSpend.destroy_all

# Standard Random Data
regions = ['APAC', 'EMEA', 'US']
months = (1..6).map { |m| Date.new(2024, m, 1) }

months.each do |month|
  regions.each do |region|
    # Default Random Values
    rev = rand(100_000..500_000)
    churn = rand(1.5..5.0).round(2)
    spend = rand(10_000..50_000)

    # -------------------------------------------------------------------------
    # 🔥 REAL CASE 1 — Story Implementation
    # -------------------------------------------------------------------------
    # Scenario: "Why did revenue drop in EMEA last month (May)?"
    # Answer: "Revenue decline appears correlated with reduced marketing spend and increased churn among mid-tier customers."
    
    # 1. APRIL (Previous Month) - The "Good" Benchmark
    if month.month == 4 && region == 'EMEA'
      rev = 450_000      # High Revenue
      churn = 1.8        # Low Churn
      spend = 40_000     # High Marketing Spend
    end

    # 2. MAY (Current Month) - The "Drop" Month
    if month.month == 5 && region == 'EMEA'
      rev = 320_000      # Low Revenue (Significant Drop)
      churn = 4.2        # High Churn (Significant Increase)
      spend = 15_000     # Low Marketing Spend (Significant Drop)
    end
    # -------------------------------------------------------------------------

    Revenue.create!(month: month, region: region, total_revenue: rev)
    ChurnMetric.create!(month: month, region: region, churn_rate: churn)
    MarketingSpend.create!(month: month, region: region, spend_amount: spend)
  end
end

puts "Seeding completed: #{Revenue.count} revenues, #{ChurnMetric.count} churn metrics, and #{MarketingSpend.count} marketing spends created."
