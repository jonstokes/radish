class CreateSubcategories < ActiveRecord::Migration[5.1]
  def change
    create_table :subcategories, id: :uuid, default: "uuid_generate_v4()"  do |t|
      t.string :name
      t.uuid :category_id
      t.string :key

      t.timestamps
    end

    add_index :subcategories, :category_id
    add_index :subcategories, :key, unique: true
  end
end
