#require 'net/http'
#
#module ActiveMerchant #:nodoc:
#  module Billing #:nodoc:
#    module Integrations #:nodoc:
#      module Pizza
#        class Notification < ActiveMerchant::Billing::Integrations::Notification
#          def complete?
#            params['']
#          end
#
#          def item_id
#            params['']
#          end
#
#          def transaction_id
#            params['']
#          end
#
#          # When was this payment received by the client.
#          def received_at
#            params['']
#          end
#
#          def payer_email
#            params['']
#          end
#
#          def receiver_email
#            params['']
#          end
#
#          def security_key
#            params['']
#          end
#
#          # the money amount we received in X.2 decimal.
#          def gross
#            params['']
#          end
#
#          # Was this a test transaction?
#          def test?
#            params[''] == 'test'
#          end
#
#          def status
#            params['']
#          end
#
#          # Acknowledge the transaction to Pizza. This method has to be called after a new
#          # apc arrives. Pizza will verify that all the information we received are correct and will return a
#          # ok or a fail.
#          #
#          # Example:
#          #
#          #   def ipn
#          #     notify = PizzaNotification.new(request.raw_post)
#          #
#          #     if notify.acknowledge
#          #       ... process order ... if notify.complete?
#          #     else
#          #       ... log possible hacking attempt ...
#          #     end
#          def acknowledge
#            payload = raw
#
#            uri = URI.parse(Pizza.notification_confirmation_url)
#
#            request = Net::HTTP::Post.new(uri.path)
#
#            request['Content-Length'] = "#{payload.size}"
#            request['User-Agent'] = "Active Merchant -- http://home.leetsoft.com/am"
#            request['Content-Type'] = "application/x-www-form-urlencoded"
#
#            http = Net::HTTP.new(uri.host, uri.port)
#            http.verify_mode    = OpenSSL::SSL::VERIFY_NONE unless @ssl_strict
#            http.use_ssl        = true
#
#            response = http.request(request, payload)
#
#            # Replace with the appropriate codes
#            raise StandardError.new("Faulty Pizza result: #{response.body}") unless ["AUTHORISED", "DECLINED"].include?(response.body)
#            response.body == "AUTHORISED"
#          end
# private
#
#          # Take the posted data and move the relevant data into a hash
#          def parse(post)
#            @raw = post
#            for line in post.split('&')
#              key, value = *line.scan( %r{^(\w+)\=(.*)$} ).flatten
#              params[key] = value
#            end
#          end
#        end
#      end
#    end
#  end
#end




module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Pizza
        module Notification

          # A helper method to parse the raw post of the request & return
          # the right Notification subclass based on the sender id.
          def self.get_notification(http_raw_data)
            params = ActiveMerchant::Billing::Integrations::Notification.new(http_raw_data).params
            Pizza.get_class(params['VK_SND_ID'])::Notification.new(params)
          end

          def bank_signature_valid?(bank_signature, service_msg_number, sigparams)
            self.class.parent.get_bank_public_key.verify(OpenSSL::Digest::SHA1.new, bank_signature, generate_data_string(service_msg_number, sigparams))
          end

          def complete?
            params['VK_SERVICE'] == '1101'
          end

          def currency
            params['VK_CURR']
          end

          # The order id we passed to the form helper.
          def item_id
            params['VK_STAMP']
          end

          def transaction_id
            params['VK_T_NO']
          end

          # When was this payment received by the client.
          # We're expecting a dd.mm.yyyy format.
          def received_at
            date = params['VK_T_DATE']
            return nil unless date
            day, month, year = *date.split('.').map(&:to_i)
            Date.civil(year, month, day)
          end

          def signature
            Base64.decode64(params['VK_MAC'])
          end

          # The money amount we received, string.
          def gross
            params['VK_AMOUNT']
          end

          # Was this a test transaction?
          def test?
            params['VK_REC_ID'] == 'testvpos'
          end

          # TODO what should be here?
          def status
            complete? ? 'Completed' : 'Failed'
          end

          # If our request was sent automatically by the bank (true) or manually
          # by the user triggering the callback by pressing a "return" button (false).
          def automatic?
            params['VK_AUTO'].upcase == 'Y'
          end

          def success?
            acknowledge && complete?
          end

          # We don't actually acknowledge the notification by making another request ourself,
          # instead, we check the notification by checking the signature that came with the notification.
          # This method has to be called when handling the notification & deciding whether to process the order.
          # Example:
          #
          #   def notify
          #     notify = Notification.new(params)
          #
          #     if notify.acknowledge
          #       ... process order ... if notify.complete?
          #     else
          #       ... log possible hacking attempt ...
          #     end
          def acknowledge
            bank_signature_valid?(signature, params['VK_SERVICE'], params)
          end

          private
          # Take the posted data and move the relevant data into a hash
          # No parsing since we're already expecting a hash.
          def parse(params)
            raise(ArgumentError, 'Need a hash') unless params.is_a?(Hash)
            @params = params
          end
        end
      end
    end
  end
end
