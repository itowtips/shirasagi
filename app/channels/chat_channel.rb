class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "ChatChannel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def cur_user
    connection.cur_user
  end

  def speak(data)
    item = Gws::Chat::Message.new
    item.cur_user = cur_user
    item.message = data["message"]
    item.save

    ActionCable.server.broadcast("ChatChannel", { html: item.html })
  end
end
