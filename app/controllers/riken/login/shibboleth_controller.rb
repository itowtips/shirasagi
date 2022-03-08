class Riken::Login::ShibbolethController < ApplicationController
  include Sns::BaseFilter
  include Sns::LoginFilter

  skip_before_action :logged_in?
  before_action :set_item

  model Riken::Auth::Shibboleth

  private

  def set_item
    @item ||= @model.find_by(filename: params[:id])
    raise "404" if @item.blank?
  end

  def login_with_env
    @item.keys.each do |key|
      rk_uid = request.env[key].presence
      next if rk_uid.blank?

      user = SS::User.where(uid: Riken.encrypt(rk_uid)).and_enabled.and_unlocked.first
      next if user.blank?

      riken_shibboleth_params = session[:riken_shibboleth]
      session.delete(:riken_shibboleth)

      params[:ref] = riken_shibboleth_params[:ref] if riken_shibboleth_params && riken_shibboleth_params.key?(:ref)
      render_login user, nil, session: true, login_path: riken_login_env_path(id: @item.filename)
      return nil
    end

    render template: "riken/login/shibboleth/login_failed"
  end

  public

  def login
    if @item.keys.any? { |key| request.env[key].present? }
      login_with_env
      return
    end

    render template: "riken/login/shibboleth/login_failed"
  end
end
