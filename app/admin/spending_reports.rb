module ActiveAdmin
  module Views
    class IndexAsAggregate < ActiveAdmin::Component
      def build(page_presenter, collection)
        add_class "aggregate-report js-aggregate-report"
        instance_exec(collection, &page_presenter.block)
      end

      def self.index_name
        "aggregate"
      end
    end
  end
end

ActiveAdmin.register TransactionRecord, as: "Spending Report" do
  config.paginate = false
  actions :index

  index as: :aggregate, download_links: false, title: "Spending Report" do
    # reorder is necessary to remove the default ordering by id
    report = Report.new(collection)

    render partial: 'reports/index', :locals => {:report => report}	
  end

  controller do
    before_action only: :index do
      if params['commit'].blank? && params['q'].blank? && params[:scope].blank?
        #country_contains or country_eq .. or depending of your filter type
        params['q'] = {
          "date_gteq_datetime" => Time.current.beginning_of_month.strftime("%Y-%m-%d"),
          "date_lteq_datetime" => Time.current.end_of_month.strftime("%Y-%m-%d")
        }
     end
    end  
  end

  filter :date
  filter :category
  filter :labels
end
