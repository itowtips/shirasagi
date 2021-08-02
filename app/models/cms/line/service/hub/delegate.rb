class Cms::Line::Service::Hub::Delegate
  include Mongoid::Document

  belongs_to :service, class_name: "Cms::Line::Service::Base"
  field :trigger_type, type: String
  field :trigger_data, type: String

  validates :service_id, presence: true
  validates :trigger_type, presence: true
  validates :trigger_data, presence: true

  def service_name
    service.try(:service)
  end

  def switch_mode(processor, event)
    return false if service.blank?
    return false if event["type"] != trigger_type

    case trigger_type
    when "message"
      return false if event.message["text"] != trigger_data
    when "postback"
      return false if event["postback"]["data"] != trigger_data
    else
      return false
    end

    processor.event_session.mode = service_name
    processor.event_session.update

    if service.switch_messages.present?
      processor.client.reply_message(event["replyToken"], service.switch_messages)
    end
    return true
  end

  def delegate(processor, events)
    return false if service.blank?
    return false if processor.event_session.mode != service_name

    service.delegate_processor(processor, events).call
    true
  end
end
