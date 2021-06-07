class Cms::Line::Hub::Delegate
  include Mongoid::Document

  field :mode, type: String
  field :trigger_type, type: String
  field :trigger_data, type: String
  field :target, type: String
  belongs_to :template, class_name: "Cms::Line::Template"

  validates :mode, presence: true
  validates :trigger_type, presence: true
  validates :trigger_data, presence: true
  validates :target, presence: true

  def target_class
    @target_class ||= "Cms::Line::Service::#{target}".constantize rescue nil
  end

  def switch_mode(service, event)
    return false if event["type"] != trigger_type

    case trigger_type
    when "message"
      return false if event.message["text"] != trigger_data
    when "postback"
      return false if event["postback"]["data"] != trigger_data
    else
      return false
    end

    if service.event_session.mode != mode
      service.event_session.mode = mode
      service.event_session.update
      service.client.reply_message(event["replyToken"], template.json) if template
    end
    return true
  end

  def delegate(service, events)
    return false if !target_class
    return false if service.event_session.mode != mode

    target_class.delegate(service, events).call
    true
  end
end
