module MWS
  class ImportService
    class << self
      def connect!(user, marketplace)
        MWS.orders(
            primary_marketplace_id: marketplace.external_marketplace_id,
            merchant_id: user.account.seller_id,
            aws_access_key_id: marketplace.aws_access_key_id,
            aws_secret_access_key: marketplace.secret_key,
            auth_token: user.account.mws_auth_token
        )
      end
    end

    def initialize(user, marketplace)
      @marketplace = MWS::ImportService.connect!(user, marketplace)
    end

    def status_check
      @marketplace.get_service_status.parse
      #return {"Status"=>"GREEN", "Timestamp"=>"2016-09-21T12:50:49.979Z"}
    end

  end
end
