module MailPage::Addon
  module MailSetting
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :receive_email, type: SS::Extensions::Lines, default: ""
      field :allow_email, type: SS::Extensions::Lines, default: ""

      permit_params :receive_email, :allow_email, :sync_delete
    end

    def create_page_from_mail(mail)
      page = MailPage::Page.new
      page.site = self.site
      page.cur_node = self
      page.layout = self.page_layout || self.layout
      page.user_id = self.user_id
      page.group_ids = self.group_ids

      page.name = mail.subject
      page.html = mail.decoded.gsub(/(\r\n?)|(\n)/, "<br />")



      #page.start_visible_date = Time.zone.now
      #page.close_visible_date = page.start_visible_date.advance(days: 2)

      page.save!
    end
  end
end
