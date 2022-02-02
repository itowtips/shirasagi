module Gws::Addon::Slack
  extend ActiveSupport::Concern
  extend SS::Addon

  set_addon_type :organization

  included do
    field :slack_oauth_token, type: String
    permit_params :slack_oauth_token
  end

  def set_slack_token
    Slack.configure do |config|
      config.token = slack_oauth_token
    end
  end
end
