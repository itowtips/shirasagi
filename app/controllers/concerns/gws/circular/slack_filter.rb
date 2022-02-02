module Gws::Circular::SlackFilter
  extend ActiveSupport::Concern

  def send_slack_msg
    init_slack_client
    send_to_channel
    send_to_dm
  end

  def init_slack_client
    @ja_slack_ids = []
    @eng_slack_ids = []
    @cur_site.set_slack_token
    @client = Slack::Web::Client.new
  end

  def send_to_channel
    @cur_site.slack_channels.each do |channel|
      begin
        slack_post_msg(channel, "both")
      rescue
        @client.conversations_list.channels.each do |conver_channel|
          next if conver_channel.name != channel.sub("#", "")

          @client.conversations_join(channel: conver_channel.id)
          slack_post_msg(channel, "both")
        end
      end
    end
  end

  def send_to_dm
    set_notify_slack_ids
    @ja_slack_ids.each { |slack_id| slack_post_msg(slack_id, "ja") }
    @eng_slack_ids.each { |slack_id| slack_post_msg(slack_id, "eng") }
  end

  def slack_post_msg(slack_id, lang)
    @client.chat_postMessage(channel: slack_id, blocks: block_opts(lang))
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
        next if @ja_slack_ids.include?(user.send_notice_slack_id)
        next if @eng_slack_ids.include?(user.send_notice_slack_id)

        separate_slack_id_by_lang(user)
      end
    end
  end

  def set_group_user_slack_ids
    return if @item.member_group_ids.blank?

    Gws::Group.in(id: @item.member_group_ids).each do |group|
      group.users.notify_slack_users.each do |user|
        next if @ja_slack_ids.include?(user.send_notice_slack_id)
        next if @eng_slack_ids.include?(user.send_notice_slack_id)

        separate_slack_id_by_lang(user)
      end
    end
  end

  def set_user_slack_ids
    return if @item.member_ids.blank?

    Gws::User.in(@item.member_ids).notify_slack_users.each do |user|
      next if @ja_slack_ids.include?(user.send_notice_slack_id)
      next if @eng_slack_ids.include?(user.send_notice_slack_id)

      separate_slack_id_by_lang(user)
    end
  end

  def separate_slack_id_by_lang(user)
    if user.lang == "ja"
      @ja_slack_ids << user.send_notice_slack_id
    else
      @eng_slack_ids << user.send_notice_slack_id
    end
  end

  def block_opts(lang)
    slack_blocks_array(lang).map do |opt|
      case opt
      when "divider"
        { type: "divider" }
      when "header"
        {
          type: "header",
          text: {
            type: "plain_text",
            text: "New Circulation Post",
          }
        }
      else #"ja" || "eng"
        {
          type: "section",
          text: {
            type: "plain_text",
            text: t("gws/circular.slack.#{opt}", name: @item.name)
          },
          fields: [
            {
              type: "mrkdwn",
              text: "<#{request.url}/#{@item.id}|#{request.url}/#{@item.id}>"
            }
          ]
        }
      end
    end
  end

  def slack_blocks_array(lang)
    case lang
    when "ja"
      return %w(header ja)
    when "eng"
      return %w(header eng)
    else
      return %w(header ja divider eng)
    end
  end
end
