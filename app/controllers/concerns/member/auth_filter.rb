module Member::AuthFilter
  extend ActiveSupport::Concern

  included do
    cattr_accessor(:member_class) { Cms::Member }
  end

  def get_member_by_session(site = false)
    return nil unless member_session_alives?

    member_id = session[:member]["member_id"]
    if site == false
      self.member_class.find member_id rescue nil
    else
      self.member_class.site(site).find member_id rescue nil
    end
  end

  def member_session_alives?(timestamp = Time.zone.now.to_i)
    session[:member] && timestamp <= session[:member]["last_logged_in"] + SS.config.cms.session_lifetime
  end

  def set_last_logged_in(timestamp = Time.zone.now.to_i)
    session[:member]["last_logged_in"] = timestamp if session[:member]
  end
end
