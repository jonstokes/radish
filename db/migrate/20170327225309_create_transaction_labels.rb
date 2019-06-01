class CreateTransactionLabels < ActiveRecord::Migration[5.1]
  def change
    create_table :labels_transaction_records, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.uuid :transaction_record_id
      t.uuid :label_id

      t.timestamps
    end

    add_index :labels_transaction_records, [:transaction_record_id, :label_id], name: :index_labels_transaction_records_on_ids
  end
end
