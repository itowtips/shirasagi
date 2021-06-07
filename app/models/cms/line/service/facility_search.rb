class Cms::Line::Service::FacilitySearch < Cms::Line::Service::Base
  def call
    events.each do |event|
      next if event["type"] != "message"
      client.reply_message(event["replyToken"], {
        type: "text",
        text: "施設検索の応答です：#{event.message["text"]}"
      })
    end
  end
end
