class Riken::Apis::Slack::TestController < ApplicationController
  include Gws::ApiFilter

  def oauth_token
    errors = []
    safe_params = params.require(:item).permit(:slack_oauth_token)
    slack_oauth_token = safe_params[:slack_oauth_token]
    if slack_oauth_token.blank?
      errors << t("errors.format", attribute: Gws::Group.t(:slack_oauth_token), message: t("errors.messages.blank"))
    end

    client = Slack::Web::Client.new(token: slack_oauth_token, logger: Rails.logger)
    result = client.auth_test
    if result[:ok]
      message = "login success to '#{result[:team]}'"
    else
      errors << "auth error"
    end

    render json: { status: errors.blank? ? "ok" : "error", errors: errors, results: [ message ] }
  rescue => e
    logger.info("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    errors << e.to_s
    render json: { status: "error", errors: errors }
  end

  def circular_slack_channels
    errors = []
    safe_params = params.require(:item).permit(:slack_oauth_token, :circular_slack_channels)
    slack_oauth_token = safe_params[:slack_oauth_token]
    if slack_oauth_token.blank?
      errors << t("errors.format", attribute: Gws::Group.t(:slack_oauth_token), message: t("errors.messages.blank"))
    end

    circular_slack_channels = safe_params[:circular_slack_channels]
    if circular_slack_channels.blank?
      errors << t("errors.format", attribute: Gws::Group.t(:circular_slack_channels), message: t("errors.messages.blank"))
    end
    if errors.present?
      render json: { status: "error", errors: errors }
      return
    end

    circular_slack_channels = SS::Extensions::Words.mongoize(circular_slack_channels)
    if circular_slack_channels.blank?
      errors << t("errors.format", attribute: Gws::Group.t(:circular_slack_channels), message: t("errors.messages.blank"))
      render json: { status: "error", errors: errors }
      return
    end

    all_channel_map = load_channel_list(slack_oauth_token)

    messages = []
    circular_slack_channels.each do |channel|
      unless all_channel_map.key?(channel)
        errors << "channel '#{channel}' is not known"
        next
      end
      unless all_channel_map[channel]
        errors << "channel '#{channel}' is not a member"
        next
      end

      messages << "channel '#{channel}' looks good"
    end

    render json: { status: errors.blank? ? "ok" : "error", errors: errors, results: messages }
  rescue => e
    logger.info("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    errors << e.to_s
    render json: { status: "error", errors: errors }
  end

  def notice_slack_channels
    errors = []
    safe_params = params.require(:item).permit(:slack_oauth_token, :notice_slack_channels)
    slack_oauth_token = safe_params[:slack_oauth_token]
    if slack_oauth_token.blank?
      errors << t("errors.format", attribute: Gws::Group.t(:slack_oauth_token), message: t("errors.messages.blank"))
    end

    notice_slack_channels = safe_params[:notice_slack_channels]
    if notice_slack_channels.blank?
      errors << t("errors.format", attribute: Gws::Group.t(:notice_slack_channels), message: t("errors.messages.blank"))
    end
    if errors.present?
      render json: { status: "error", errors: errors }
      return
    end

    notice_slack_channels = SS::Extensions::Words.mongoize(notice_slack_channels)
    if notice_slack_channels.blank?
      errors << t("errors.format", attribute: Gws::Group.t(:notice_slack_channels), message: t("errors.messages.blank"))
      render json: { status: "error", errors: errors }
      return
    end

    all_channel_map = load_channel_list(slack_oauth_token)

    messages = []
    notice_slack_channels.each do |channel|
      unless all_channel_map.key?(channel)
        errors << "channel '#{channel}' is not known"
        next
      end
      unless all_channel_map[channel]
        errors << "channel '#{channel}' is not a member"
        next
      end

      messages << "channel '#{channel}' looks good"
    end

    render json: { status: errors.blank? ? "ok" : "error", errors: errors, results: messages }
  rescue => e
    logger.info("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    errors << e.to_s
    render json: { status: "error", errors: errors }
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
