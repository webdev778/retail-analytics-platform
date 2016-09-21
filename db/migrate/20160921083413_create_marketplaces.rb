class CreateMarketplaces < ActiveRecord::Migration[5.0]
  def change
    create_table :marketplaces do |t|
      t.belongs_to :user, index: true
      t.belongs_to :account, index: true

      t.string :external_marketplace_id
      t.string :aws_access_key_id
      t.string :secret_key
      t.string :status

      t.timestamps
    end
  end
end
