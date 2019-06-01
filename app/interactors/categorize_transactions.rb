class CategorizeTransactions
  include Lasershark

  context_with(
    Class.new(BaseContext) do
      attr_accessor :query, :scope, :count
    end
  )
  delegate :query, :scope, to: :context

  before { context.count = 0 }

  def call
    begin
      categorize!
    rescue Exception => e
      context.fail!(error: e.message)
    end
  end

  def categorize!
    TransactionRecord.transaction do
      TransactionRecord.where(scope).where(query).find_each do |entry|
        categorizations = TransactionRecord.
          where(scope).
          where.not(query.merge(category_key: "check")).
          where(category_key: entry.category_key).
          pluck(:category_id, :subcategory_id)

        next if categorizations.empty?
        
        categorizations.map! { |row| "#{row.first}::#{row.last}" }
        category_counts = {}
        categorizations.each do |categorization|
          category_counts[categorization] ||= 0
          category_counts[categorization] += 1
        end
        winner = Hash[category_counts.sort_by{|k, v| v}.reverse].first

        category_id, subcategory_id = *winner.first.split("::")
        entry.category_id = category_id
        entry.subcategory_id = subcategory_id
        context.count += 1 if entry.valid? && entry.changed?
        entry.save!
      end
    end
  end
end