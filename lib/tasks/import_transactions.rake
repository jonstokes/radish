desc "import transaction_records from mint"
task :import => :environment do
  filename = Rails.root.join('tmp', 'transactions.csv')

  ImportTransactions.call(filename: filename)
end

task :clean_import => :environment do
  TransactionRecord.delete_all
  Rake::Task['import'].execute
end