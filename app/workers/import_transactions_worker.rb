class ImportTransactionsWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(opts)
    file = opts["file"]
    account_id = opts["account_id"]

    user = User.find_by(id: opts["user_id"])
    upload = Upload.new(
      user: user,
      status: 0,
      data: file
    )
    upload.save!

    unless account = Account.find_by(id: account_id)
      error = "Account #{account_id} not found."
      upload.update(error: error)
      raise error
    end

    import_transactions = ImportTransactions.call(
      file: file,
      account: account,
      user: user,
      upload: upload
    )

    if import_transactions.success?
      upload.update(status: 1)
    else
      upload.update(error: import_transactions.error)
      raise import_transactions.error
    end
  end
end