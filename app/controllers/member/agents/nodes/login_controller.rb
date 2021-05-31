class Member::Agents::Nodes::LoginController < ApplicationController
  include Cms::NodeFilter::View
  include Member::LoginFilter

  skip_before_action :logged_in?, only: [:login, :logout, :callback, :failure]

  private

  def get_params
    params.require(:item).permit(:email, :password)
  rescue
    raise "400"
  end

  def set_member_and_redirect(member)
    set_member member
    Member::ActivityLog.create(
      cur_site: @cur_site,
      cur_member: member,
      activity_type: "login",
      remote_addr: remote_addr,
      user_agent: request.user_agent)

    ref = @cur_node.make_trusted_full_url(params[:ref] || flash[:ref])
    ref = @cur_node.redirect_full_url if ref.blank?
    ref = @cur_site.full_url if ref.blank?
    flash.discard(:ref)

    redirect_to ref
  end

  public

  def login
    @item = Cms::Member.new
    unless request.post?
      @error = flash[:alert]
      flash[:ref] = params[:ref]
      return
    end

    @item.attributes = get_params
    member = Cms::Member.site(@cur_site).and_enabled.where(email: @item.email, password: SS::Crypt.crypt(@item.password)).first
    unless member
      @error = t "sns.errors.invalid_login"
      return
    end

    set_member_and_redirect member
  end

  def logout
    # discard all session info
    reset_session
    flash.discard(:ref)
    redirect_to member_login_path
  end

  def callback
    auth = request.env["omniauth.auth"]

    #require "pry"
    #binding.pry

    #uid = auth.uid
    #site = SS::Site.first
    #client = Line::Bot::Client.new do |config|
    #  config.channel_secret = site.line_channel_secret
    #  config.channel_token = site.line_channel_access_token
    #end
    #messages = [
    #  {
    #    type: "text",
    #    text: "Hello, world"
    #  }
    #]
    #client.push_message(uid, messages)

    member = Cms::Member.site(@cur_site).and_enabled.where(oauth_type: auth.provider, oauth_id: auth.uid).first
    if member.blank?
      # 外部認証していない場合、ログイン情報を保存してから、ログインさせる
      Cms::Member.create_auth_member(auth, @cur_site)
      member = Cms::Member.site(@cur_site).and_enabled.where(oauth_type: auth.provider, oauth_id: auth.uid).first
    end

    set_member_and_redirect member
  end

  def failure
    session[:auth_site] = nil
    session[session_member_key] = nil
    flash.discard(:ref)

    redirect_to "#{@cur_node.url}/login.html"
  end
end
