class UpdateTransactions
  include Lasershark

  context_with(
    Class.new(BaseContext) do
      attr_accessor :transaction_ids, :inputs
      attr_accessor :transactions, :category_id, :subcategory_id
    end
  )
  delegate :transactions, :category_id, :subcategory_id, to: :context

  before do
    context.transactions = context.transaction_ids.map do |transaction_id|
      TransactionRecord.find_by(id: transaction_id) || context.fail!(error: "Can't find transaction #{transaction_id}")
    end
  end

  before do
    context.category_id, context.subcategory_id = *context.inputs[:category].split("::")
  end

  def call
    transactions.each do |transaction|
      transaction.update!(
        category_id: category_id,
        subcategory_id: subcategory_id
      )
    end
  end
end