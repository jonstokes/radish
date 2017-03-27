class CreateTransactionLabels < ActiveRecord::Migration[5.1]
  def change
    create_table :transaction_labels, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.uuid :transaction_id
      t.uuid :label_id

      t.timestamps
    end
  end
end
