module Urgency::Addon
  module Mail
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :original_mail, type: String
      field :start_visible_date, type: DateTime
      field :close_visible_date, type: DateTime

      permit_params :original_mail
      permit_params :start_visible_date, :close_visible_date

      validate :validate_visible_date
    end

    def validate_visible_date
      if close_visible_date.present? && start_visible_date.present? && start_visible_date >= close_visible_date
        errors.add :close_visible_date, :greater_than, count: t(:start_visible_date)
      end
    end
  end
end
