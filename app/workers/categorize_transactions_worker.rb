class CategorizeTransactionsWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(opts)
    categorize_transactions = CategorizeTransactions.call(opts)

    if categorize_transactions.failure?
      raise categorize_transactions.error
    end
  end
end