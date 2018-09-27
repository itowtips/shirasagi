module Opendata::Addon::UpdateFrequency
  extend SS::Addon
  extend ActiveSupport::Concern

  included do
    field :update_frequency, type: String
    field :update_plan_date, type: DateTime
    field :update_plan_date_mail_state, type: String, default: "disabled"

    permit_params :update_frequency, :update_plan_date, :update_plan_date_mail_state
  end

  def update_plan_date_mail_state_options
    %w(disabled enabled).map do |v|
      [ I18n.t("ss.options.state.#{v}"), v ]
    end
  end
end
