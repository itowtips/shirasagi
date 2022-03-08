module Riken::Addon::ShibbolethSetting
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    field :diagnosis_state, type: String
    permit_params :diagnosis_state
    validates :diagnosis_state, inclusion: { in: %w(hide show), allow_blank: true }
  end

  def diagnosis_state_options
    %w(hide show).map do |v|
      [ I18n.t("ss.options.state.#{v}"), v ]
    end
  end
end
