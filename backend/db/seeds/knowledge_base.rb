# db/seeds/knowledge_base.rb
articles = [
  {
    title: "Q2 2024 Revenue Analysis - EMEA",
    content: "The revenue drop in EMEA during May 2024 was primarily due to a 48-hour unplanned server outage in our Frankfurt data center which prevented enterprise customers from renewing subscriptions."
  },
  {
    title: "Marketing Strategy 2024",
    content: "Our 2024 strategy focuses on increasing marketing spend in APAC by 20% to capture the growing mid-market segment. We are shifting away from traditional LinkedIn ads towards influencer-led technical content."
  },
  {
    title: "Churn Reduction Initiative",
    content: "Customer churn increased in US during Q1 2024. The feedback indicates that users are finding the new dashboard UI confusing. We have planned a UI simplification sprint for Q3."
  }
]

client = GeminiClient.new

articles.each do |attr|
  puts "Embedding: #{attr[:title]}..."
  embedding = client.embed(attr[:content])
  KnowledgeBaseArticle.create!(
    title: attr[:title],
    content: attr[:content],
    embedding: embedding
  )
end

puts "Knowledge base seeded!"
