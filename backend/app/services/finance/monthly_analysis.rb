module Finance
  class MonthlyAnalysis
    def initialize(region:, month:)
      @region = region
      @month = month
      @previous_month = month.prev_month
    end

    def call
      {
        revenue: compare_revenue,
        marketing_spend: compare_marketing,
        churn: compare_churn
      }
    end

    private

    def compare_revenue
      current = revenue_for(@month)
      previous = revenue_for(@previous_month)

      percent_change(current, previous)
    end

    def compare_marketing
      current = marketing_for(@month)
      previous = marketing_for(@previous_month)

      percent_change(current, previous)
    end

    def compare_churn
      current = churn_for(@month)
      previous = churn_for(@previous_month)

      (current - previous).round(2)
    end

    def revenue_for(month)
      Revenue.find_by(month: month, region: @region)&.total_revenue.to_f
    end

    def marketing_for(month)
      MarketingSpend.find_by(month: month, region: @region)&.spend_amount.to_f
    end

    def churn_for(month)
      ChurnMetric.find_by(month: month)&.churn_rate.to_f
    end

    def percent_change(current, previous)
      return 0 if previous.zero?
      (((current - previous) / previous) * 100).round(2)
    end
  end
end
