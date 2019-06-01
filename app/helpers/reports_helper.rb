module ReportsHelper
  def current_month
    Time.current.strftime("%B")
  end
end
