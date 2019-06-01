namespace :utils do
  desc "Generate new category keys"
  task generate_category_keys: :environment do
    TransactionRecord.find_each do |record|
      record.send(:set_category_key!)
      record.save!
    end
  end
end
