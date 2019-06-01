class CreateImports < ActiveRecord::Migration[5.2]
  def change
    create_table :uploads, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.references :user
      t.integer :status
      t.string :error
      t.text :data

      t.timestamps
    end

    add_column :transaction_records, :upload_id, :uuid
  end
end
