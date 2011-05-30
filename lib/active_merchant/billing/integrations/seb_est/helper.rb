#module ActiveMerchant #:nodoc:
#  module Billing #:nodoc:
#    module Integrations #:nodoc:
#      module SebEst
#        class Helper < ActiveMerchant::Billing::Integrations::Helper
#          # Replace with the real mapping
#          mapping :account, ''
#          mapping :amount, ''
#
#          mapping :order, ''
#
#          mapping :customer, :first_name => '',
#                             :last_name  => '',
#                             :email      => '',
#                             :phone      => ''
#
#          mapping :billing_address, :city     => '',
#                                    :address1 => '',
#                                    :address2 => '',
#                                    :state    => '',
#                                    :zip      => '',
#                                    :country  => ''
#
#          mapping :notify_url, ''
#          mapping :return_url, ''
#          mapping :cancel_return_url, ''
#          mapping :description, ''
#          mapping :tax, ''
#          mapping :shipping, ''
#        end
#      end
#    end
#  end
#end
module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module SebEst #:nodoc:
        class Helper < ActiveMerchant::Billing::Integrations::Helper #:nodoc:
          include Pizza::Common
          include Pizza::Helper

          def vk_charset
            'UTF-8'
          end
        end
      end
    end
  end
end
