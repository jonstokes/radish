class AddImporterToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :import_adapter_name, :string
  end
end
