module Gws::Slack::SendNotificationJob
  private

  def send_slack_msg(item)
    @item = item
    @dm_success_count = 0
    @dm_error_count = 0
    @channel_success_count = 0
    @channel_error_count = 0

    init_slack_client
    send_to_channel
    Rails.logger.info { "チャンネル通知成功件数: #{@channel_success_count}件、チャンネル通知失敗件数: #{@channel_error_count}件" }

    return if notice_post_class?
    send_to_dm
    Rails.logger.info { "DM通知成功件数: #{@dm_success_count}件、DM通知失敗件数: #{@dm_error_count}件" }
  end

  def init_slack_client
    @slack_ids = []
    @client = site.slack_client
  end

  def send_to_channel
    if notice_post_class?
      site.notice_slack_channels.each do |channel|
        begin
          slack_post_msg(channel)
          @channel_success_count += 1
        rescue => e
          @channel_error_count += 1
          Rails.logger.error { "#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}" }
        end
      end
    elsif site.circular_slack_channels.present?
      site.circular_slack_channels.each do |channel|
        begin
          slack_post_msg(channel)
          @channel_success_count += 1
        rescue => e
          @channel_error_count += 1
          Rails.logger.error { "#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}" }
        end
      end
    end
  end

  def send_to_dm
    set_notify_slack_ids
    @slack_ids.each do |slack_id|
      begin
        slack_post_msg(slack_id)
        @dm_success_count += 1
      rescue => e
        @dm_error_count += 1
        Rails.logger.error { "#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}" }
      end
    end
  end

  def slack_post_msg(slack_id)
    Retriable.retriable(on_retry: method(:on_each_retry), base_interval: 1, multiplier: 1) do
      @client.chat_postMessage(channel: slack_id, blocks: block_opts)
    end
  end

  def on_each_retry(err, try, elapsed, interval)
    Rails.logger.warn(
      "#{err.class}: '#{err.message}' - #{try} tries in #{elapsed} seconds and #{interval} seconds until the next try."
    )
  end

  def set_notify_slack_ids
    set_custom_group_user_slack_ids
    set_group_user_slack_ids
    set_user_slack_ids
  end

  def set_custom_group_user_slack_ids
    return if @item.member_custom_group_ids.blank?

    Gws::CustomGroup.in(id: @item.member_custom_group_ids).each do |group|
      group.users.notify_slack_users.each do |user|
        next if @slack_ids.include?(user.send_notice_slack_id)

        @slack_ids << user.send_notice_slack_id
      end
    end
  end

  def set_group_user_slack_ids
    return if @item.member_group_ids.blank?

    Gws::Group.in(id: @item.member_group_ids).each do |group|
      group.users.notify_slack_users.each do |user|
        next if @slack_ids.include?(user.send_notice_slack_id)

        @slack_ids << user.send_notice_slack_id
      end
    end
  end

  def set_user_slack_ids
    return if @item.member_ids.blank?

    Gws::User.in(id: @item.member_ids).notify_slack_users.each do |user|
      next if @slack_ids.include?(user.send_notice_slack_id)

      @slack_ids << user.send_notice_slack_id
    end
  end

  def block_opts
    [
        {
          type: "header",
          text: {
            type: "plain_text",
            text: header_text,
          }
        },
        {
          type: "section",
          text: {
            type: "plain_text",
            text: section_text
          }
        },
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "<#{show_page_url}>"
          }
        }
    ]
  end

  def header_text
    if notice_post_class?
      "A New Notice Post"
    else
      "A New Circulation Post"
    end
  end

  def section_text
    if notice_post_class?
      I18n.t("gws/notice.slack", name: @item.name, locale: "en")
    else
      I18n.t("gws/circular.slack", name: @item.name, locale: "en")
    end
  end

  def show_page_url
    scheme = site.canonical_scheme.presence || SS.config.gws.canonical_scheme.presence || "http"
    domain = site.canonical_domain.presence || SS.config.gws.canonical_domain
    url_helper = Rails.application.routes.url_helpers

    if notice_post_class?
      url_helper.gws_notice_readable_url(
        protocol: scheme, host: domain, folder_id: '-',
        category_id: '-', site: site.id, id: @item.id
      )
    else
      url_helper.gws_circular_post_url(
        protocol: scheme, host: domain, site: site.id, id: @item.id
      )
    end
  end

  def notice_post_class?
    @item.instance_of?(Gws::Notice::Post)
  end
end
