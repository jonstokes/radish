class Label < ApplicationRecord
  has_many :transactions, through: :transaction_labels
end
