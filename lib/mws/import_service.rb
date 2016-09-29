module MWS
  class ImportService
    class << self
      def connect!(user, marketplace)
        MWS::FulfillmentInboundShipment::Client.new(
            primary_marketplace_id: marketplace.external_marketplace_id,
            merchant_id: marketplace.account.seller_id,
            aws_access_key_id: marketplace.aws_access_key_id ,
            aws_secret_access_key: marketplace.secret_key,
            auth_token: marketplace.account.mws_auth_token
        )
        # MWS.orders(
        #     primary_marketplace_id: marketplace.external_marketplace_id,
        #     merchant_id: user.account.seller_id,
        #     aws_access_key_id: marketplace.aws_access_key_id,
        #     aws_secret_access_key: marketplace.secret_key,
        #     auth_token: user.account.mws_auth_token
        # )
      end
    end

    def initialize(user, marketplace)
      @marketplace = MWS::ImportService.connect!(user, marketplace)
    end

    def status_check
      #return {"Status"=>"GREEN", "Timestamp"=>"2016-09-21T12:50:49.979Z"}
      @marketplace.get_service_status.parse
    end

    def get_fulfillment_inbound_shipments_list
      # client.list_inbound_shipments({shipment_status_list: 'closed'})
      # statuses = %w(working shipped in_transit delivered checked_in receiving closed cancelled)
      statuses = 'closed'
      response = @marketplace.list_inbound_shipments({ shipment_status_list: statuses })
      response = response.parse
      p '!!'
      p response
      p '!!'
      get_fulfillment_inbound_shipments_list_by_next_token(response["NextToken"]) if response["NextToken"].present?
    end

    def get_fulfillment_inbound_shipments_list_by_next_token(next_token)
      # client.list_inbound_shipments({shipment_status_list: 'closed'})
      # statuses = %w(working shipped in_transit delivered checked_in receiving closed cancelled)
      response = @marketplace.list_inbound_shipments_by_next_token(next_token)
      response = response.parse
      p '@@'
      p response
      p '@@'
      get_fulfillment_inbound_shipments_list_by_next_token(response["NextToken"]) if response["NextToken"].present?
    end
  end
end
