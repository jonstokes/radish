class Account < ApplicationRecord
  has_many :transaction_records

  def import_adapter
    @import_adapter ||=  import_adapter_name.constantize.new(self)
  end
end
