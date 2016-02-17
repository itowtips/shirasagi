module Ezine::Addon
  module Subscription
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      embeds_ids :subscriptions, class_name: "Cms::Node"
      permit_params subscription_ids: []
    end
  end
end
