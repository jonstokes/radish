class CreateCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :categories, id: :uuid, default: "uuid_generate_v4()"  do |t|
      t.string :name
      t.string :key

      t.timestamps
    end

    add_index :categories, :key, unique: true
  end
end
