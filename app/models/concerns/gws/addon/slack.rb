module Gws::Addon::Slack
  extend ActiveSupport::Concern
  extend SS::Addon

  set_addon_type :organization

  included do
    field :slack_oauth_token, type: String
    permit_params :slack_oauth_token
  end

  def slack_client
    return if slack_oauth_token.blank?
    Slack::Web::Client.new(token: slack_oauth_token, logger: Rails.logger)
  end
end
