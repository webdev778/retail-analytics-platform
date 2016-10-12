class InventoriesController < ApplicationController
  def index
    @received_inventories = ReceivedInventory.where(marketplace_id: current_user.marketplaces.pluck(:id)).page params[:page]
  end
end
