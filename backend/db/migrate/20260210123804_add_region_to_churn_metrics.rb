class AddRegionToChurnMetrics < ActiveRecord::Migration[7.2]
  def change
    add_column :churn_metrics, :region, :string
  end
end
