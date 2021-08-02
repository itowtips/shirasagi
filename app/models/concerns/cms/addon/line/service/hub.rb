module Cms::Addon
  module Line::Service::Hub
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      embeds_many :delegates, class_name: "Cms::Line::Service::Hub::Delegate"
      field :expired_text, type: String
      field :expired_minutes, type: Integer, default: 10

      permit_params delegates: [:service_id, :trigger_type, :trigger_data]
      permit_params :expired_text, :expired_minutes

      before_validation :validate_delegates
    end

    def validate_delegates
      self.delegates = delegates.select { |item| item.service.present? }
    end
  end
end
