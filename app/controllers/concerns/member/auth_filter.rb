module Member::AuthFilter
  extend ActiveSupport::Concern

  def session_member_key
    "#{@cur_site.host}.member"
  end

  def get_member_by_session
    return nil unless member_session_alives?

    member_id = session[session_member_key]["member_id"]
    Cms::Member.site(@cur_site).and_enabled.find member_id rescue nil
  end

  def member_session_alives?(timestamp = Time.zone.now.to_i)
    return false if !@cur_site
    session[session_member_key] && timestamp <= session[session_member_key]["last_logged_in"] + SS.config.cms.session_lifetime
  end

  def set_last_logged_in(timestamp = Time.zone.now.to_i)
    return false if !@cur_site
    session[session_member_key]["last_logged_in"] = timestamp if session[session_member_key]
  end

  def member_login_node
    @member_login_node ||= begin
      node = Member::Node::Login.site(@cur_site).and_public.first
      node.present? ? node : false
    end
  end

  def member_login_path
    return false unless member_login_node
    "#{member_login_node.url}login.html"
  end
end
