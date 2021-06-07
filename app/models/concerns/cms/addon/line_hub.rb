module Cms::Addon
  module LineHub
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      embeds_many :line_delegates, class_name: "Cms::Line::Hub::Delegate"
      permit_params line_delegates: [:mode, :trigger_type, :trigger_data, :target, :template_id]
      before_validation :validate_line_delegates
    end

    def validate_line_delegates
      self.line_delegates = line_delegates.select do |item|
        item.mode.present? || item.trigger_type.present? || item.trigger_data.present? || item.target.present?
      end
    end
  end
end
