module Urgency::Addon
  module MailSetting
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :receive_email, type: SS::Extensions::Lines, default: ""

      permit_params :receive_email
    end

    def create_page_from_mail(mail)
      node = self

      from = mail.from[0]
      body = mail.body.to_s
      subject = mail.subject

      page = Urgency::Page.new
      page.site = node.site
      page.cur_node = node

      page.name = subject
      page.html = body.gsub("\n", "<br />")
      page.layout = node.layout

      page.start_visible_date = Time.zone.now
      page.close_visable_date = page.start_visible_date.tommorow

      page.save
    end
  end
end
