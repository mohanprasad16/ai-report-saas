class UpdateEmbeddingDimensions < ActiveRecord::Migration[7.2]
  def change
    change_column :knowledge_base_articles, :embedding, :vector, limit: 3072
  end
end