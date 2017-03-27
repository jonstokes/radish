class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.datetime :date
      t.text :description
      t.text :original_description
      t.float :amount
      t.boolean :debit
      t.uuid :account_id
      t.text :notes
       
      t.timestamps
    end
  end
end
