module Gws::Addon::Circular::GroupSetting
  extend ActiveSupport::Concern
  extend SS::Addon
  include Gws::Break

  set_addon_type :organization

  included do
    field :circular_default_due_date, type: Integer, default: 7
    field :circular_max_member, type: Integer
    field :circular_filesize_limit, type: Integer
    field :circular_delete_threshold, type: Integer, default: 3
    field :circular_files_break, type: String, default: 'vertically'
    field :circular_new_days, type: Integer
    field :circular_slack_channels, type: SS::Extensions::Words

    permit_params :circular_default_due_date, :circular_max_member,
      :circular_filesize_limit, :circular_delete_threshold,
      :circular_files_break, :circular_new_days, :circular_slack_channels

    validates :circular_default_due_date, numericality: true
    validates :circular_delete_threshold, numericality: true
    validates :circular_files_break, inclusion: { in: %w(vertically horizontal), allow_blank: true }

    after_save :join_bot_to_slack_channels

    alias_method :circular_files_break_options, :break_options
  end

  def circular_delete_threshold_options
    I18n.t('gws/circular.options.circular_delete_threshold').
      map.
      with_index.
      to_a
  end

  def circular_delete_threshold_name
    I18n.t('gws/circular.options.circular_delete_threshold')[circular_delete_threshold]
  end

  def circular_filesize_limit_in_bytes
    return if circular_filesize_limit.blank?

    circular_filesize_limit * 1_024 * 1_024
  end

  def circular_new_days
    self[:circular_new_days].presence || 7
  end

  private

  def join_bot_to_slack_channels
    client = slack_client
    bot_user_id = client.auth_test.user_id rescue nil

    return if bot_user_id.nil?

    client.conversations_list.channels.each do |channel|
      next if !self.circular_slack_channels.include?("##{channel.name}")

      users_in_channel = client.conversations_members(channel: channel.id).members
      next if users_in_channel.include?(bot_user_id)

      client.conversations_join(channel: channel.id)
    end
  end
end
