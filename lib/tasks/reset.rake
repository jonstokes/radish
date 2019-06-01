desc "reset the app"
task :reset => :environment do
  [Category, Subcategory, TransactionRecord].each(&:delete_all)

  Rake::Task['db:seed'].execute

  Rake::Task['import'].execute
end