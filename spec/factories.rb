FactoryBot.define do
  factory :account do
    sequence(:name) { Faker::Bank.name }
    import_adapter_name { "ImportAdapter::Chase" }
  end

  factory :category do
    sequence(:name) { |i| "Category #{i}" }
  end

  factory :subcategory do
    category
    sequence(:name) { |i| "Subcategory #{i}" }
  end

  factory :transaction_record do
    account
    category

    date { Faker::Date.between(1.year.ago, Date.today) }
    description  { Faker::Company.name }
    original_description { "#{Faker::Company.name.upcase} #{Faker::Company.duns_number}" }
    amount { Faker::Number.between(-1000, 1000) }

    after :build do |entry|
      adapter = entry.account.import_adapter
      entry.description = adapter.clean_description(entry.description)
      entry.category_key = adapter.generate_category_key(entry.description)
      entry.key = adapter.generate_key(entry.attributes.symbolize_keys)
    end  
  end

  factory :user do
    email { Faker::Internet.email }
    password  { Faker::Internet.password }
  end
end