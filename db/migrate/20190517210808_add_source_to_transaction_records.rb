class AddSourceToTransactionRecords < ActiveRecord::Migration[5.2]
  def up
    add_column :transaction_records, :source, :jsonb
    add_column :transaction_records, :category_key, :string
  end

  def down
    remove_column :transaction_records, :source
    remove_column :transaction_records, :category_key
  end
end
