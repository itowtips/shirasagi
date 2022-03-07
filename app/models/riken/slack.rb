module Riken::Slack
  module SlackTestServiceBase
    extend ActiveSupport::Concern
    include ActiveModel::Model

    included do
      attr_accessor :index, :params
      attr_reader :errors, :messages
    end

    def initialize(attributes = {})
      super
      @errors = []
      @messages = []
    end

    def status
      errors.blank? ? "ok" : "error"
    end

    def slack_oauth_token
      params[:slack_oauth_token]
    end

    def human_attribute_name(attr_name)
      Gws::Group.t(attr_name)
    end

    def add_error(attr_name, message)
      errors << I18n.t("errors.format", attribute: human_attribute_name(attr_name), message: I18n.t("errors.messages.#{message}"))
    end
  end

  module SlackChannelTest
    extend ActiveSupport::Concern

    def call
      if slack_oauth_token.blank?
        add_error(:slack_oauth_token, :blank)
      end
      if slack_channels.blank?
        add_error(:slack_channels, :blank)
      end
      if errors.present?
        return
      end

      channel_to_test = slack_channels[index]
      if channel_to_test.blank?
        add_error(:slack_channels, :blank)
        return
      end

      all_channel_map = load_channel_list(slack_oauth_token)
      if !all_channel_map.key?(channel_to_test)
        errors << "channel '#{channel_to_test}' is not known"
      elsif !all_channel_map[channel_to_test]
        errors << "channel '#{channel_to_test}' is not a member"
      else
        messages << "channel '#{channel_to_test}' looks good"
      end
    end

    private

    def load_channel_list(slack_oauth_token)
      all_channel_map = {}

      client = Slack::Web::Client.new(token: slack_oauth_token, logger: Rails.logger)
      client.conversations_list do |result|
        next unless result[:ok]

        result[:channels].each do |channel|
          name = channel[:name]
          is_member = channel[:is_member]

          if name.present?
            all_channel_map["##{name}"] = is_member
          end

          name_normalized = channel[:name_normalized]
          if name_normalized.present? && name_normalized != name
            all_channel_map["##{name_normalized}"] = is_member
          end
        end
      end

      all_channel_map
    end
  end

  module SlackChannelJoin
    extend ActiveSupport::Concern

    def call
      if slack_oauth_token.blank?
        add_error(:slack_oauth_token, :blank)
      end
      if slack_channels.blank?
        add_error(:slack_channels, :blank)
      end
      if errors.present?
        return
      end

      channel_to_join = slack_channels[index]
      if channel_to_join.blank?
        add_error(:slack_channels, :blank)
        return
      end

      channel = find_channel(channel_to_join)
      if channel.blank?
        errors << "channel '#{channel_to_join}' is not known"
        return
      end

      client = Slack::Web::Client.new(token: slack_oauth_token, logger: Rails.logger)
      result = client.conversations_join(channel: channel.id)
      if result[:warning] == "already_in_channel"
        messages << "already in channel '#{channel_to_join}'"
      else
        messages << "successfully joined to channel '#{channel_to_join}'"
      end
    end

    def find_channel(channel_to_join)
      client = Slack::Web::Client.new(token: slack_oauth_token, logger: Rails.logger)
      client.conversations_list.channels.each do |channel|
        return channel if "##{channel.name}" == channel_to_join
      end
    end
  end

  module SlackChannelTestPost
    extend ActiveSupport::Concern

    included do
      attr_accessor :test_url
    end

    def call
      if slack_oauth_token.blank?
        add_error(:slack_oauth_token, :blank)
      end
      if slack_channels.blank?
        add_error(:slack_channels, :blank)
      end
      if errors.present?
        return
      end

      channel_to_post = slack_channels[index]
      if channel_to_post.blank?
        add_error(:slack_channels, :blank)
        return
      end

      blocks = [
        { type: "header", text: { type: "plain_text", text: "This is a test", } },
        {
          type: "section",
          text: { type: "plain_text", text: "This is a test" },
          fields: [
            { type: "mrkdwn", text: "<#{test_url}|#{test_url}>" }
          ]
        }
      ]

      client = Slack::Web::Client.new(token: slack_oauth_token, logger: Rails.logger)
      result = client.chat_postMessage(channel: channel_to_post, blocks: blocks)

      messages << "success"
    end

    def find_channel(channel_to_join)
      client = Slack::Web::Client.new(token: slack_oauth_token, logger: Rails.logger)
      client.conversations_list.channels.each do |channel|
        return channel if "##{channel.name}" == channel_to_join
      end
    end
  end

  class CircularSlackChannelTestService
    include SlackTestServiceBase
    include SlackChannelTest

    def slack_channels
      params[:circular_slack_channels]
    end

    def human_attribute_name(attr_name)
      return Gws::Group.t(:circular_slack_channels) if attr_name == :slack_channels
      super
    end
  end

  class CircularSlackChannelJoinService
    include SlackTestServiceBase
    include SlackChannelJoin

    def slack_channels
      params[:circular_slack_channels]
    end

    def human_attribute_name(attr_name)
      return Gws::Group.t(:circular_slack_channels) if attr_name == :slack_channels
      super
    end
  end

  class CircularSlackChannelTestPostService
    include SlackTestServiceBase
    include SlackChannelTestPost

    def slack_channels
      params[:circular_slack_channels]
    end

    def human_attribute_name(attr_name)
      return Gws::Group.t(:circular_slack_channels) if attr_name == :slack_channels
      super
    end
  end

  class NoticeSlackChannelTestService
    include SlackTestServiceBase
    include SlackChannelTest

    def slack_channels
      params[:notice_slack_channels]
    end

    def human_attribute_name(attr_name)
      return Gws::Group.t(:notice_slack_channels) if attr_name == :slack_channels
      super
    end
  end

  class NoticeSlackChannelJoinService
    include SlackTestServiceBase
    include SlackChannelJoin

    def slack_channels
      params[:notice_slack_channels]
    end

    def human_attribute_name(attr_name)
      return Gws::Group.t(:notice_slack_channels) if attr_name == :slack_channels
      super
    end
  end

  class NoticeSlackChannelTestPostService
    include SlackTestServiceBase
    include SlackChannelTestPost

    def slack_channels
      params[:notice_slack_channels]
    end

    def human_attribute_name(attr_name)
      return Gws::Group.t(:notice_slack_channels) if attr_name == :slack_channels
      super
    end
  end
end
