ActiveAdmin.register Upload do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
  permit_params :account_id, :file

  actions :all 

  config.sort_order = 'created_at_desc'

  index do
    selectable_column
    column :created_at
    column :user do |upload|
      upload.user.email
    end
    column :status
    column "Entries" do |upload|
      upload.transaction_records.count
    end
    column "Start Date" do |upload|
      if starting_entry = upload.transaction_records.order("date asc").first
        starting_entry.date.strftime("%m/%d/%Y")
      end
    end
    column "End Date" do |upload|
      if ending_entry = upload.transaction_records.order("date desc").first
        ending_entry.date.strftime("%m/%d/%Y")
      end
    end
    column "Accounts" do |upload|
      upload.transaction_records.distinct(:account_id).pluck(:account_id).map { |aid| Account.find(aid).name }
    end
    
    actions defaults: true do |upload|
      link_to "Categorize", controller: "admin/uploads", action: "categorize", id: upload
    end
  end

  member_action :categorize, method: :get do
    CategorizeTransactionsWorker.perform_async(
      scope: { upload_id: params[:id] },
      query: { category_id: Category.find_by(name: "Uncategorized").id }
    )
    redirect_to admin_uploads_path, notice: "Categorizing entries."
  end

  form do |f|
    f.inputs do
      f.input :account_id, as: :select, collection: [["Import from Mint", nil]] + Account.pluck(:name, :id)
      f.input :file, as: :file
    end
    f.actions
  end

  controller do
    def create
      account_id = params[:upload][:account_id]
      read_file = ReadCsv.call(file: params[:upload][:file])
  
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
end
