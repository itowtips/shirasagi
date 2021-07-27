class Cms::Agents::Nodes::LineHubController < ApplicationController
  include Cms::NodeFilter::View

  protect_from_forgery except: [:index]

  public

  def index
    client ||= Line::Bot::Client.new do |config|
      config.channel_secret = @cur_site.line_channel_secret
      config.channel_token = @cur_site.line_channel_access_token
    end

    processor = Cms::Line::Service::Processor::Hub.new(
      site: @cur_site,
      node: @cur_node,
      client: client,
      request: request)
    processor.parse_request

    if !processor.valid_signature?
      Rails.logger.error("invalid line request")
      head :bad_request
      return
    end

    if processor.webhook_verify_request?
      head :ok
      Rails.logger.info("verified line request")
      return
    end

    processor.call
    head :ok
  end
end
