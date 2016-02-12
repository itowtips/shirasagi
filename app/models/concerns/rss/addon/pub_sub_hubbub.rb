module Rss::Addon
  module PubSubHubbub
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :hub_url, type: String
      field :topic_urls, type: SS::Extensions::Words
      field :lease_seconds, type: Integer
      field :secret, type: String
      field :rss_max_docs, type: Integer
      permit_params :hub_url, :topic_urls, :lease_seconds, :secret, :rss_max_docs
    end

    def callback_url
      "#{full_url}subscriber"
    end

    def subscribe(mode = 'subscribe')
      return if topic_urls.blank?

      topic_urls.each do |topic_url|
        params = { 'hub.callback' => callback_url, 'hub.mode' => mode, 'hub.topic' => topic_url }
        params['hub.lease_seconds'] = lease_seconds if lease_seconds
        params['hub.secret'] = secret if secret
        Faraday.post(hub_url, params)
      end
    end

    def unsubscribe
      subscribe('unsubscribe')
    end
  end
end
