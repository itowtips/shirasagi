class Cms::Line::Service::Processor::AccountLink < Cms::Line::Service::Processor::Base
  def start_messages
    client = site.line_client
    res = client.create_link_token(event_session.channel_user_id)
    link_token = JSON.parse(res.body)["linkToken"]

    #{
    #  "type": "template",
    #  "altText": "Account Link",
    #  "template": {
    #    "type": "buttons",
    #    "text": "Account Link",
    #    "actions": [{
    #        "type": "uri",
    #        "label": "Account Link",
    #        "uri": "http://localhost:3000/account_link?linkToken=#{link_token}"
    #    }]
    #  }
    #}

    nonce = SecureRandom.uuid
    {
      "type": "template",
      "altText": "Account Link",
      "template": {
        "type": "buttons",
        "text": "Account Link",
        "actions": [{
            "type": "uri",
            "label": "Account Link",
            "uri": "https://access.line.me/dialog/bot/accountLink?linkToken=#{link_token}&nonce=#{nonce}"
        }]
      }
    }
  end
end
