class CreateRevenues < ActiveRecord::Migration[7.2]
  def change
    create_table :revenues do |t|
      t.date :month
      t.string :region
      t.integer :total_revenue

      t.timestamps
    end
  end
end
