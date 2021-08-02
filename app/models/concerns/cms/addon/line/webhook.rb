module Cms::Addon
  module Line::Webhook
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      belongs_to :webhook_service, class_name: "Cms::Line::Service::Base"
      permit_params :webhook_service_id
    end
  end
end
