class Upload < ApplicationRecord
  belongs_to :user
  has_many :transaction_records, dependent: :destroy

  attr_accessor :account_id, :file
end