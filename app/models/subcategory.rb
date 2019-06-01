class Subcategory < ApplicationRecord
  include Keyable

  belongs_to :category
  has_many :transaction_records

  def full_name
    "#{category.name} > #{name}"
  end

  def full_id
    "#{category.id}::#{id}"
  end
end
