class Cms::Agents::Nodes::SnsLoginController < ApplicationController
  include Cms::NodeFilter::View
  include SS::AuthFilter
  include History::LogFilter
  helper Cms::ListHelper

  layout "cms/sns_login"

  private
    def get_params
      params.require(:item).permit(:uid, :email, :password)
    end

    def set_user(user, opt = {})
      if opt[:session]
        session[:user] = SS::Crypt.encrypt("#{user._id},#{remote_addr},#{request.user_agent}")
        session[:password] = SS::Crypt.encrypt(opt[:password]) if opt[:password].present?
      end
      @cur_user = user
    end

    def unset_user(opt = {})
      session[:user] = nil
      session[:password] = nil
      @cur_user = nil
    end

  public
    def login
      if !request.post?
        @item = SS::User.new email: params[:email]
        return
      end

      safe_params  = get_params
      email_or_uid = safe_params[:email].presence || safe_params[:uid]
      password     = safe_params[:password]

      @item = SS::User.authenticate(email_or_uid, password)
      unless @item
        @item  = SS::User.new email: email_or_uid
        @error = t "sns.errors.invalid_login"
        return
      end

      set_user @item, session: true, password: password
      ref = @cur_site.full_url
      ref = params[:ref] if params[:ref].present?
      redirect_to ref
    end

    def logout
      @cur_user = get_user_by_session

      if @cur_user
        put_history_log
        unset_user
      end

      ref = @cur_site.full_url
      ref = params[:ref] if params[:ref].present?
      redirect_to ref
    end
end
