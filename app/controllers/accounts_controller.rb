# frozen_string_literal: true
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
        MWS::ImportService.initial_import(@account.marketplace, true)
        format.html { redirect_to accounts_path, notice: 'Account was successfully added' }
      else
        format.html { render :new }
      end
    end
  end

  def destroy
    @account = Account.find(params[:id])
    @account.destroy
    redirect_to accounts_path, notice: 'Your marketplace account and all imported data was successfully deleted'
  end

  private

  def account_params
    marketplace_attributes = [:external_marketplace_id, :aws_access_key_id, :secret_key]
    parameters = params.require(:account).permit(:seller_id,
                                                 :mws_auth_token,
                                                 marketplace_attributes: marketplace_attributes).merge(user: current_user)
    parameters[:marketplace_attributes] = parameters[:marketplace_attributes].merge(user: current_user)

    parameters
  end
end
