class Cms::Line::Service::Processor::MyPlan < Cms::Line::Service::Processor::Base
  def call
    events.each do |event|
      next if event["type"] != "message"
      client.reply_message(event["replyToken"], {
        type: "text",
        text: "今日の予定の応答です：#{event.message["text"]}"
      })
    end
  end
end
