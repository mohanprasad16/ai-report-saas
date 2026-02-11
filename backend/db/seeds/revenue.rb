Revenue.destroy_all

# APAC
Revenue.create!(region: "APAC", month: Date.new(2024, 3, 1), total_revenue: 10000)
Revenue.create!(region: "APAC", month: Date.new(2024, 4, 1), total_revenue: 12000)
Revenue.create!(region: "APAC", month: Date.new(2024, 5, 1), total_revenue: 15000)

# EMEA (Declining Trend)
Revenue.create!(region: "EMEA", month: Date.new(2024, 3, 1), total_revenue: 50000)
Revenue.create!(region: "EMEA", month: Date.new(2024, 4, 1), total_revenue: 48000)
Revenue.create!(region: "EMEA", month: Date.new(2024, 5, 1), total_revenue: 40000)

# US (Stable)
Revenue.create!(region: "US", month: Date.new(2024, 3, 1), total_revenue: 80000)
Revenue.create!(region: "US", month: Date.new(2024, 4, 1), total_revenue: 82000)
Revenue.create!(region: "US", month: Date.new(2024, 5, 1), total_revenue: 81000)

puts "Revenue data seeded for forecasting!"
