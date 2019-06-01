class ChangeLabelTextToName < ActiveRecord::Migration[5.2]
  def change
    rename_column :labels, :text, :name
  end
end
