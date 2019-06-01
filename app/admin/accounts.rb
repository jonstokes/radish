ActiveAdmin.register Account do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :import_adapter_name
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  form do |f|
    f.inputs do
      f.input :name
      f.input :import_adapter_name, as: :select, collection: %w(ImportAdapter::Chase ImportAdapter::ChaseCard ImportAdapter::Amex)
    end
    f.actions
  end


  index do
    column :name
    column "Entries" do |account|
      account.transaction_records.count
    end
    column "First Entry" do |account|
      if first_entry = account.transaction_records.order("date asc").first
        first_entry.date.strftime("%m/%d/%Y")
      end
    end
    column "Last Entry" do |account|
      if last_entry = account.transaction_records.order("date desc").first
        last_entry.date.strftime("%m/%d/%Y")
      end
    end
    column :import_adapter_name
    actions
  end


end
