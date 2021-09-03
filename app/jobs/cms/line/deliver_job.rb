class Cms::Line::DeliverJob < Cms::ApplicationJob
  include Cms::Line::BaseJob

  def perform(message_id)
    item = Cms::Line::Message.site(site).where(id: message_id).first
    raise "message not found! #{message_id}" if item.blank?

    begin
      deliver_message(item)
    rescue => e
      Rails.logger.error("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    ensure
      item.completed = Time.zone.now
      item.test_completed = nil
      item.deliver_state = "completed"
      item.deliver_date = nil
      item.save
    end
  end
end
