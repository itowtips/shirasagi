class MailPage::ImportJob < Cms::ApplicationJob
  def put_log(message)
    Rails.logger.info(message)
  end

  def perform(data)
    mail = ::Mail.new(data)
    from = mail.from[0]
    to = mail.to[0]

    MailPage::Node::Page.site(site).each do |node|
      node.create_page_from_mail(mail)
    end

    #Urgency::Node::Page.site(site).in(receive_email: to).each do |node|
    #  same_address = node.allow_email.index(from)
    #  same_domain = node.allow_email.select { |domain| /^.+?@#{domain}$/ =~ from }.present?
    #  if same_address || same_domain
    #    node.create_page_from_mail(mail)
    #  end
    #end
  end
end
