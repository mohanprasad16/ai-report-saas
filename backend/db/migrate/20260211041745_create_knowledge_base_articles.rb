class CreateKnowledgeBaseArticles < ActiveRecord::Migration[7.2]
  def change
    enable_extension "vector"

    create_table :knowledge_base_articles do |t|
      t.string :title
      t.text :content
      t.vector :embedding, limit: 768

      t.timestamps
    end
  end
end