module Riken::MS365::GraphApi

  EMPTY_PARAMS = {}.freeze

  mattr_accessor :base_interval, instance_accessor: false
  self.base_interval = Rails.env.test? ? 0.5 : 15 # seconds

  def self.tokens
    @tokens ||= {}
  end

  def self.create_client(url, token: nil)
    http_client = Faraday.new(url: url) do |builder|
      builder.request  :url_encoded
      builder.response :logger, Rails.logger
      builder.adapter Faraday.default_adapter
    end
    http_client.headers[:user_agent] += " (SHIRASAGI/#{SS.version}; PID/#{Process.pid})"
    if token
      http_client.headers[:prefer] = "outlook.timezone=\"#{Time.zone.tzinfo.identifier}\""
      http_client.headers[:content_type] = "application/json"
      http_client.headers[:authorization] = "Bearer #{token}"
    end
    http_client
  end

  def self.refresh_token(site)
    http_client = Riken::MS365::GraphApi.create_client("https://login.microsoftonline.com/")

    token_params = {
      client_id: site.riken_ms365_client_id,
      scope: "https://graph.microsoft.com/.default",
      client_secret: Riken.decrypt(site.riken_ms365_client_secret),
      grant_type: "client_credentials"
    }
    resp = http_client.post("/#{site.riken_ms365_tenant_id}/oauth2/v2.0/token", token_params)
    raise "unable to obtain tokens" unless resp.status == 200

    json = JSON.parse(resp.body)
    Riken::MS365::GraphApi.tokens[site.id] = json["access_token"]
  end

  def self.get(site, url, params = nil)
    on_retry = proc do |err, try, elapsed, interval|
      Rails.logger.fatal do
        "#{err.class}: '#{err.message}' - #{try} tries in #{elapsed} seconds and #{interval} seconds until the next try."
      end
      Riken::MS365::GraphApi.tokens[site.id] = nil
    end

    Retriable.retriable(on_retry: on_retry, base_interval: Riken::MS365::GraphApi.base_interval) do
      # ensure to obtain access token for site
      token = Riken::MS365::GraphApi.tokens[site.id] || Riken::MS365::GraphApi.refresh_token(site)

      http_client = Riken::MS365::GraphApi.create_client("https://graph.microsoft.com/", token: token)

      resp = http_client.get url, params || Riken::MS365::GraphApi::EMPTY_PARAMS
      raise "#{resp.status}: '#{resp.body}'" if resp.status != 200

      JSON.parse(resp.body)
    end
  end

  def self.each_room(site, room_list_id: nil, &block)
    if room_list_id.present?
      url = "/v1.0/places/#{room_list_id}/microsoft.graph.roomlist/rooms"
    else
      url = "/v1.0/places/microsoft.graph.room"
    end
    loop do
      body = Riken::MS365::GraphApi.get(site, url)
      break if body.blank?

      body["value"].each(&block)

      url = body["@odata.nextLink"]
      break if url.blank?
    end
  end

  def self.each_room_list(site, &block)
    url = "/v1.0/places/microsoft.graph.roomlist"
    loop do
      body = Riken::MS365::GraphApi.get(site, url)
      break if body.blank?

      body["value"].each(&block)

      url = body["@odata.nextLink"]
      break if url.blank?
    end
  end

  def self.each_event(site, room_id, from: nil, to: nil, &block)
    return if room_id.blank?

    filters = []
    if from
      filters << "start/dateTime ge '#{from.in_time_zone.strftime("%Y-%m-%dT%H:%M:%S")}'"
    end
    if to
      filters << "end/dateTime lt '#{(to.in_time_zone + 1.day).strftime("%Y-%m-%dT%H:%M:%S")}'"
    end
    params = nil
    if filters.present?
      params = { "$filter" => filters.join(" and ") }
    end

    url = "/v1.0/users/#{room_id}/events"
    loop do
      body = Riken::MS365::GraphApi.get(site, url, params)
      break if body.blank?

      body["value"].each(&block)

      url = body["@odata.nextLink"]
      break if url.blank?
    end
  end

  def self.create_event(site, room_id, params)
    return if room_id.blank?

    transaction_id = SecureRandom.uuid

    # https://docs.microsoft.com/en-us/graph/api/resources/datetimetimezone?view=graph-rest-1.0
    attendees = params[:attendees].split(/\R/).map do |attendee|
      {
        "emailAddress" => {
          address: attendee
        },
        type: "required"
      }
    end
    event_params = {
      subject: params[:subject],
      body: {
        "contentType" => "HTML",
        "content" => params[:body],
      },
      start: {
        "dateTime" => params[:start].presence.try { |time| time.in_time_zone.strftime("%Y-%m-%dT%H:%M:%S") },
        "timeZone" => Time.zone.tzinfo.identifier
      },
      end: {
        "dateTime" => params[:end].presence.try { |time| time.in_time_zone.strftime("%Y-%m-%dT%H:%M:%S") },
        "timeZone" => Time.zone.tzinfo.identifier
      },
      attendees: attendees,
      "allowNewTimeProposals" => true,
      "transactionId" => transaction_id
    }

    on_retry = proc do |err, try, elapsed, interval|
      Rails.logger.fatal do
        "#{err.class}: '#{err.message}' - #{try} tries in #{elapsed} seconds and #{interval} seconds until the next try."
      end
      Riken::MS365::GraphApi.tokens[site.id] = nil
    end

    Retriable.retriable(on_retry: on_retry, base_interval: Riken::MS365::GraphApi.base_interval) do
      # ensure to obtain access token for site
      token = Riken::MS365::GraphApi.tokens[site.id] || Riken::MS365::GraphApi.refresh_token(site)

      http_client = Riken::MS365::GraphApi.create_client("https://graph.microsoft.com/", token: token)

      resp = http_client.post "/v1.0/users/#{room_id}/events", event_params.to_json
      raise "#{resp.status}: '#{resp.body}'" if resp.status != 201

      resp
    end
  end
end
