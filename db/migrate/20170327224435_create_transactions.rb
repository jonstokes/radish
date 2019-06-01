class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transaction_records, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.datetime :date
      t.text :description
      t.text :original_description
      t.monetize :amount
      t.uuid :account_id
      t.text :notes
      t.uuid :category_id
      t.uuid :subcategory_id
      t.string :key

      t.timestamps
    end

    add_index :transaction_records, :category_id
    add_index :transaction_records, :subcategory_id
    add_index :transaction_records, :account_id
    add_index :transaction_records, :key, unique: true
  end
end
