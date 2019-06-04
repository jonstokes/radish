task categorize_amex: :environment do
  opts =  {
      query: {
      category_id: Category.find_by(name: "Uncategorized").id
    }
    scope: {
      account_id: Account.find_by(name: "Amex Platinum Card").id,
      date: [1.year.ago.beginning_of_year..1.year.ago.end_of_year]
    }
  }
  interactor = CategorizeTransactions.call(opts)
  puts "Success? #{interactor.success?}"
  puts "Error: #{interactor.error}"
  puts "Count: #{interactor.count}"
end