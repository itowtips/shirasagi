module Gws::Addon::Notice::GroupSetting
  extend ActiveSupport::Concern
  extend SS::Addon

  set_addon_type :organization

  MAX_NOTICE_SLACK_CHANNELS = 10

  included do
    field :notice_new_days, type: Integer
    field :notice_slack_channels, type: SS::Extensions::Words

    permit_params :notice_new_days, notice_slack_channels: []

    validates :notice_slack_channels, length: { maximum: MAX_NOTICE_SLACK_CHANNELS }
  end

  def notice_new_days
    self[:notice_new_days].presence || 7
  end
end
