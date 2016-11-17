class AddLastPeriodicalInformationGettingToMarketplace < ActiveRecord::Migration[5.0]
  def change
    add_column :marketplaces, :last_periodic_information_getting, :datetime
  end
end
