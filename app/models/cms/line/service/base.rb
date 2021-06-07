class Cms::Line::Service::Base
  include ActiveModel::Model

  attr_accessor :site, :node, :client
  attr_accessor :request, :body
  attr_accessor :signature, :events
  attr_accessor :event_session

  def valid_signature?
    client.validate_signature(body, signature)
  end

  def webhook_verify_request?
    @events.blank?
  end

  def channel_user_id(event)
    event["source"]["userId"] rescue nil
  end

  def call
  end

  class << self
    def setup(site, node, client, request)
      signature = request.env["HTTP_X_LINE_SIGNATURE"]
      body = request.body.read
      events = client.parse_events_from(body) rescue nil

      self.new(
        site: site,
        node: node,
        client: client,
        request: request,
        signature: signature,
        body: body,
        events: events,
        event_session: nil
      )
    end

    def delegate(delegator, events)
      self.new(
        site: delegator.site,
        node: delegator.node,
        client: delegator.client,
        request: delegator.request,
        signature: delegator.signature,
        body: delegator.body,
        events: events,
        event_session: delegator.event_session
      )
    end
  end
end
