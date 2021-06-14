module Pippi::Member::Addon
  module AdditionalAttributes
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      field :subscribe_line_message, type: String, default: "active"
      field :child_age_situations, type: Array, default: []

      validates :subscribe_line_message, inclusion: { in: %w(active expired) }
      validate :validate_child_age_situations

      permit_params :subscribe_line_message
      permit_params child_age_situations: []
    end

    def subscribe_line_message_options
      %w(active expired).map { |m| [ I18n.t("pippi.options.subscribe_line_message.#{m}"), m ] }.to_a
    end

    def child_age_situations_options
      I18n.t("pippi.options.child_age_situations").map { |k, v| [v, k] }
    end

    def label_child_age_situations(keys = nil)
      keys ||= I18n.t("pippi.options.child_age_situations").keys.map(&:to_s)
      keys.map do |k|
        child_age_situations.include?(k) ? I18n.t("pippi.options.child_age_situations.#{k}") : nil
      end.compact.join(", ")
    end

    def validate_child_age_situations
      self.child_age_situations = child_age_situations.select(&:present?)

      keys = I18n.t("pippi.options.child_age_situations").keys.map(&:to_s)
      child_age_situations.each do |child_age_situation|
        if !keys.include?(child_age_situation)
          errors.add :child_age_situations, :inclusion
          break
        end
      end
    end
  end
end
