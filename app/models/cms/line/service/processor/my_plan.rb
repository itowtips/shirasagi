class Cms::Line::Service::Processor::MyPlan < Cms::Line::Service::Processor::Base
  def call
    events.each do |event|
      next if event["type"] != "message"
      client.reply_message(event["replyToken"], {
        type: "text",
        text: "今日の予定の応答です：https://liff.line.me/1656323567-2p6qBdq5 #{event.message["text"]}"
      })
    end
  end
end
