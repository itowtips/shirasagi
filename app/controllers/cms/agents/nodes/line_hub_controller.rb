class Cms::Agents::Nodes::LineHubController < ApplicationController
  include Cms::NodeFilter::View

  protect_from_forgery except: [:index]

  public

  def index
    client ||= Line::Bot::Client.new do |config|
      config.channel_secret = @cur_site.line_channel_secret
      config.channel_token = @cur_site.line_channel_access_token
    end

    service = Cms::Line::Service::Hub.setup(@cur_site, @cur_node, client, request)
    if !service.valid_signature?
      Rails.logger.error("invalid line request")
      head :bad_request
      return
    end

    if service.webhook_verify_request?
      head :ok
      Rails.logger.info("verified line request")
      return
    end

    service.call
    head :ok
  end
end
