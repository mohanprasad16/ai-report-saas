class KnowledgeBaseArticle < ApplicationRecord
  has_neighbors :embedding
end
