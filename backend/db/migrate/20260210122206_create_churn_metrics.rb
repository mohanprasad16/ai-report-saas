class CreateChurnMetrics < ActiveRecord::Migration[7.2]
  def change
    create_table :churn_metrics do |t|
      t.date :month
      t.float :churn_rate

      t.timestamps
    end
  end
end
