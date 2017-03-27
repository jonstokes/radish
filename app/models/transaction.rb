class Transaction < ApplicationRecord
  has_many :labels, through: :transaction_labels
  belongs_to :account

  def signed_amount
    if debit?
      "-#{amount}"
    else
      amount
    end
  end
end
