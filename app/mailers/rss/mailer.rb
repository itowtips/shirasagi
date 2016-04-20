class Rss::Mailer < ActionMailer::Base

  def urgency_notify_mail(node, before_layout_name, after_layout_name)
    @node = node
    @site = node.site
    @before_layout_name = before_layout_name
    @after_layout_name = after_layout_name
    #sender = "#{@node.sender_name} <#{@node.sender_email}>"
    @subject = "[RSS緊急災害レイアウト切替]#{node.name} - #{node.site.name}"

    mail from: @node.from_email, to: @node.notice_email
  end
end
