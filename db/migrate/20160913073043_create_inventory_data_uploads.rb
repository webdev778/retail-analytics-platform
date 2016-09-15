class CreateInventoryDataUploads < ActiveRecord::Migration[5.0]
  def change
    create_table :inventory_data_uploads do |t|
      t.attachment :file_for_import
      t.string :description
      t.datetime :finished_at
      t.integer :imported_new
      t.integer :already_exist
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
