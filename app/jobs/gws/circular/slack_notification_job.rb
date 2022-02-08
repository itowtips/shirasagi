class Gws::Circular::SlackNotificationJob < Gws::ApplicationJob
  include Gws::Slack::SendNotificationJob

  def perform(item_id)
    item = Gws::Circular::Post.find(item_id)
    send_slack_msg(item)
  end
end
