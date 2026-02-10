class CreateAiReports < ActiveRecord::Migration[7.2]
  def change
    create_table :ai_reports do |t|
      t.text :prompt
      t.text :response
      t.string :model
      t.integer :prompt_tokens
      t.integer :completion_tokens
      t.integer :total_tokens

      t.timestamps
    end
  end
end
