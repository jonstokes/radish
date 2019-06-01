class Report
  Report::Category = Struct.new(:id, :name, :total)

  attr_reader :scope

  def initialize(scope)
    @scope = scope
  end

  def transactions
    scope.where.not(category_id: excluded_category_ids)
  end

  def each_category(&block)
    categories.each do |category|
      yield category
    end
  end

  def each_subcategory_for(category, &block)
    subcategories_for(category).each do |subcategory|
      yield subcategory
    end
  end

  def grand_total
    @grand_total ||= Money.new(transactions.sum(:amount_cents))
  end

  def categories
    @categories ||= ::Category.all.to_a.reject do |category|
        category_total(category).zero?
      end.sort do |a, b|
        a.name <=> b.name
      end.map do |category|
        Report::Category.new(category.id, category.name, category_total(category))
      end
  end

  def subcategories_for(category)
    Subcategory.where(category_id: category.id).to_a.reject do |subcategory|
        subcategory_total(subcategory).zero?
      end.sort do |a, b|
        a.name <=> b.name
      end.map do |subcategory|
        Report::Category.new(subcategory.id, subcategory.name, subcategory_total(subcategory))
      end
  end

  def category_total(category)
    Money.new transactions.in_category(category).sum(:amount_cents)
  end

  def subcategory_total(subcategory)
    Money.new transactions.in_subcategory(subcategory).sum(:amount_cents)
  end

  def excluded_category_ids
    @excluded_category_ids ||= ::Category.where(name: %w(Transfer Income Taxes)).pluck(:id)
  end
end