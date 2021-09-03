class Cms::Line::TestDeliverJob < Cms::ApplicationJob
  include Cms::Line::BaseJob

  def perform(message_id, test_member_ids)
    item = Cms::Line::Message.site(site).where(id: message_id).first
    raise "message not found! #{message_id}" if item.blank?

    test_members = Cms::Line::TestMember.site(site).in(id: test_member_ids).to_a
    raise "test members not found! #{test_member_ids}" if test_member_ids.blank?

    begin
      deliver_test_message(item, test_members)
    rescue => e
      Rails.logger.error("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    ensure
      item.test_completed = Time.zone.now
      item.save
    end
  end
end
