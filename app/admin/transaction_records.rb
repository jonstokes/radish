ActiveAdmin.register TransactionRecord do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# TODO: Link users and transaction records
# scope_to :current_user

permit_params :account_id,
              :full_category_id,
              :date,
              :description,
              :original_description,
              :amount_cents,
              :notes,
              label_ids: []
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
  filter :account
  filter :category
  filter :subcategory
  filter :labels
  filter :date
  filter :description
  filter :original_description
  filter :amount_cents
  filter :notes
  filter :upload, as: :select, collection: -> { Upload.order("created_at desc").limit(10).pluck(:created_at, :id) }
  filter :category_id_not_eq, label: 'Except Category', as: :select, collection: ->{ Category.all }
  filter :subcategory_id_not_eq, label: 'Except Subcategory', as: :select, collection: ->{ Subcategory.all }
  filter :without_label_in, label: 'Except Label', as: :select, collection: ->{ Label.all }

  config.sort_order = 'date_desc'

  index do
    selectable_column
    column :account
    column :date do |transaction_record|
      transaction_record.date.strftime("%m/%d/%Y")
    end
    column :description do |tr|
      div tr.description
      div 
        em small tr.category_key
    end
    column "Amount", sortable: :amount_cents do |transaction_record|
      number_to_currency transaction_record.amount
    end
    column "Category" do |transaction_record|
      transaction_record.full_category_name
    end
    actions

    div class: "panel" do
      h3 "Total: #{number_to_currency(collection.pluck(:amount_cents).reduce(:+) / 100.00)}"
    end  
  end

  form do |f|
    f.inputs do
      f.input :account
      f.input :full_category_id, as: :select, collection: Category.category_select
      f.input :date
      f.input :description
      f.input :original_description
      f.input :amount_cents
      f.input :notes
      f.input :labels, as: :check_boxes
    end
    f.actions
  end

  batch_action :edit, form: {
    category: Category.category_select,
  } do |ids, inputs|
    # inputs is a hash of all the form fields you requested
    update_transactions = UpdateTransactions.call(transaction_ids: ids, inputs: inputs)
    if update_transactions.success?
      redirect_to collection_path, notice: "Successfully updated with #{inputs}"
    else
      redirect_to collection_path, alert: update_transactions.error
    end
  end

  action_item :only => :index do
    link_to 'Upload CSV', :action => 'upload_csv'
  end

  collection_action :upload_csv do
    render "admin/csv/upload_csv"
  end

  collection_action :import_csv, :method => :post do
    account_id = params[:dump][:account_id]
    read_file = ReadCsv.call(file: params[:dump][:file])

    if read_file.success?
      ImportTransactionsWorker.perform_async(
        account_id: account_id,
        user_id: current_user.id,
        file: read_file.output
      )
      redirect_to :action => :index, notice: "Importing transactions for user #{current_user.email}..."  
    else
      redirect_to :action => :index, alert: read_file.error  
    end
  end
end
