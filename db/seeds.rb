# Create default categories
categories_file = Rails.root.join("config", "categories.yml")
YAML.load_file(categories_file).each do |category_name, subcategory_names|
  category = Category.find_by_key(category_name) || Category.create(name: category_name)
  next unless subcategory_names.present?
  subcategory_names.each do |subcategory_name|
    subcategory_name = subcategory_name.is_a?(String) ? subcategory_name : subcategory_name.keys.first
    next if category.subcategories.find_by_key(subcategory_name)
    category.subcategories.create(name: subcategory_name)
  end
end

[
  "Recurring",
  "One-off",
  "Reimbursable",
  "Tax Deductible",
  "Investigate",
  "Telecom",
  "Tax Related",
  "Fixed",
  "Vacation"
].each do |label_text|
  Label.create!(text: label_text)
end
User.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?