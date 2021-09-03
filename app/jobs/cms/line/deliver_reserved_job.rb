class Cms::Line::DeliverReservedJob < Cms::ApplicationJob
  include Cms::Line::BaseJob

  def perform(opts = {})
    now = opts[:now]
    now ||= Time.zone.now

    items = Cms::Line::Message.site(site).where(
      :deliver_state => "ready",
      :deliver_date.ne => nil,
      :deliver_date.lte => now).to_a

    items.each do |item|
      begin
        item.publish
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
end
