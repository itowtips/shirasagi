module Gws::Addon::Notice::GroupSetting
  extend ActiveSupport::Concern
  extend SS::Addon

  set_addon_type :organization

  included do
    field :notice_new_days, type: Integer
    field :notice_slack_channels, type: SS::Extensions::Words

    permit_params :notice_new_days, :notice_slack_channels

    after_save :join_bot_to_slack_channels
  end

  def notice_new_days
    self[:notice_new_days].presence || 7
  end

  private

  def join_bot_to_slack_channels
    client = slack_client
    bot_user_id = client.auth_test.user_id rescue nil

    return if bot_user_id.nil?

    client.conversations_list.channels.each do |channel|
      next if !self.notice_slack_channels.include?("##{channel.name}")

      users_in_channel = client.conversations_members(channel: channel.id).members
      next if users_in_channel.include?(bot_user_id)

      client.conversations_join(channel: channel.id)
    end
  end
end
