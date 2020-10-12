class ImportTransactions
  include Lasershark

  context_with(
    Class.new(BaseContext) do
      attr_accessor :file, :account, :import_adapter, :upload
      attr_accessor :csv_input
    end
  )
  delegate :file, :csv_input, :account, :import_adapter, :upload, to: :context

  before do
    context.import_adapter = account ? account.import_adapter : ImportAdapter::Mint
    context.csv_input = CSV.parse(file, import_adapter.csv_options)
  end

  def call
    csv_input.each do |line|
      # Skip header
      next if line[0].strip == "Date"

      new_entry = TransactionRecord.new(
        import_adapter.translate(line).merge(upload: upload)
      )
      context.fail!(error: new_entry.errors) unless new_entry.valid?
      begin
        new_entry.save
      rescue ActiveRecord::RecordNotUnique
      end
    end
  end
end