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

  def circular_slack_channel
    index = params[:index]
    raise "404" if !index.numeric?

    safe_params = params.require(:item).permit(:slack_oauth_token, circular_slack_channels: [])
    service = Riken::Slack::CircularSlackChannelTestService.new(index: index.to_i, params: safe_params)
    service.call

    render json: { status: service.status, errors: service.errors, results: service.messages }
  rescue => e
    logger.info("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    render json: { status: "error", errors: [ e.to_s ] }
  end

  def circular_slack_channel_join
    index = params[:index]
    raise "404" if !index.numeric?

    safe_params = params.require(:item).permit(:slack_oauth_token, circular_slack_channels: [])
    service = Riken::Slack::CircularSlackChannelJoinService.new(index: index.to_i, params: safe_params)
    service.call

    render json: { status: service.status, errors: service.errors, results: service.messages }
  rescue => e
    logger.info("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    render json: { status: "error", errors: [ e.to_s ] }
  end

  def circular_slack_channel_post
    index = params[:index]
    raise "404" if !index.numeric?

    safe_params = params.require(:item).permit(:slack_oauth_token, circular_slack_channels: [])
    service = Riken::Slack::CircularSlackChannelTestPostService.new(
      index: index.to_i, params: safe_params, test_url: gws_portal_url)
    service.call

    render json: { status: service.status, errors: service.errors, results: service.messages }
  rescue => e
    logger.info("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    render json: { status: "error", errors: [ e.to_s ] }
  end

  def notice_slack_channel
    index = params[:index]
    raise "404" if !index.numeric?

    safe_params = params.require(:item).permit(:slack_oauth_token, notice_slack_channels: [])
    service = Riken::Slack::NoticeSlackChannelTestService.new(index: index.to_i, params: safe_params)
    service.call

    render json: { status: service.status, errors: service.errors, results: service.messages }
  rescue => e
    logger.info("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    render json: { status: "error", errors: [ e.to_s ] }
  end

  def notice_slack_channel_join
    index = params[:index]
    raise "404" if !index.numeric?

    safe_params = params.require(:item).permit(:slack_oauth_token, notice_slack_channels: [])
    service = Riken::Slack::NoticeSlackChannelJoinService.new(index: index.to_i, params: safe_params)
    service.call

    render json: { status: service.status, errors: service.errors, results: service.messages }
  rescue => e
    logger.info("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    render json: { status: "error", errors: [ e.to_s ] }
  end

  def notice_slack_channel_post
    index = params[:index]
    raise "404" if !index.numeric?

    safe_params = params.require(:item).permit(:slack_oauth_token, notice_slack_channels: [])
    service = Riken::Slack::NoticeSlackChannelTestPostService.new(
      index: index.to_i, params: safe_params, test_url: gws_portal_url)
    service.call

    render json: { status: service.status, errors: service.errors, results: service.messages }
  rescue => e
    logger.info("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    render json: { status: "error", errors: [ e.to_s ] }
  end
end
