module Cms::Addon
  module MailSetting
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :notice_mail_state, type: String
      field :from_mail, type: String
      field :notice_mail, type: SS::Extensions::Lines
      permit_params :from_mail, :notice_mail, :notice_mail_state
    end
    
    def notice_mail_state_options
      [
        [I18n.t('cms.options.state.disabled'), 'disabled'],
        [I18n.t('cms.options.state.enabled'), 'enabled'],
      ]
    end
    
    def notice_mail_enabled?
      notice_mail_state == 'enabled'
    end
  end
end
