class CreateMarketingSpends < ActiveRecord::Migration[7.2]
  def change
    create_table :marketing_spends do |t|
      t.date :month
      t.string :region
      t.integer :spend_amount

      t.timestamps
    end
  end
end
