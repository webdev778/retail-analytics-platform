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
        MWS::ImportService.initial_import(@account.marketplace)
        format.html { redirect_to accounts_path, notice: 'Account was successfully added.' }
      else
        format.html { render :new }
      end
    end
  end

  private

  def account_params
    parameters = params.require(:account).permit(:seller_id, :mws_auth_token, marketplace_attributes: [:external_marketplace_id, :aws_access_key_id, :secret_key]).merge(user: current_user)
    parameters[:marketplace_attributes] = parameters[:marketplace_attributes].merge(user: current_user)
    parameters
  end
end
