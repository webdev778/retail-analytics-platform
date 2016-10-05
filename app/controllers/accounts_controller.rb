class AccountsController < ApplicationController
  def index
    @accounts = current_user.accounts.includes(:marketplace)
  end

  def new
    @account = Account.new
    @account.build_marketplace
  end

  def create
    @account = Account.new(account_params)

    respond_to do |format|
      if @account.save
        Marketplace.create(account_params['marketplace_attributes'].merge(user: current_user, account: @account))
        format.html { redirect_to accounts_path, notice: 'Account was successfully added.' }
      else
        format.html { render :new }
      end
    end
  end

  private

  def account_params
    params.require(:account).permit(:seller_id, :mws_auth_token, marketplace_attributes: [:external_marketplace_id, :aws_access_key_id, :secret_key]).merge(user: current_user)
  end
  #
  def marketplace_params
    params.require(:account).permit(marketplace_fields: [:marketplace_id, :aws_access_key_id, :secret_key, :mws_auth_token])
  end
end
