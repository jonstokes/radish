class Category < ApplicationRecord
  include Keyable

  has_many :subcategories
  has_many :transaction_records

  module ClassMethods
    def category_select
      # Check if the db exists
      ActiveRecord::Base.connection
      # TODO: rewrite with a map or something more elegant, and move it to a module
      categories = []
      Category.pluck(:name, :id).each do |category_attrs|
        categories << category_attrs
        Subcategory.where(category_id: category_attrs.last).pluck(:name, :id).each do |subcategory_attrs|
          categories << ["#{category_attrs.first} > #{subcategory_attrs.first}", "#{category_attrs.last}::#{subcategory_attrs.last}"]
        end
      end
      categories
    rescue
      nil
    end
  end
  extend ClassMethods
end
