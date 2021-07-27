module Cms::Addon
  module Line::ServiceSetting
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      embeds_many :line_delegates, class_name: "Cms::Line::Hub::Delegate"
      permit_params line_delegates: [:service_id, :trigger_type, :trigger_data]
      before_validation :validate_line_delegates
    end

    def validate_line_delegates
      self.line_delegates = line_delegates.select { |item| item.service.present? }
    end
  end
end
