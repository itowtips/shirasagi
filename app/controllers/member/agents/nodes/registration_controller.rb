class Member::Agents::Nodes::RegistrationController < ApplicationController
  include Cms::NodeFilter::View

  model Cms::Member

  private
    def fix_params
      { cur_site: @cur_site }
    end

    def permit_fields
      @model.permitted_fields
    end

    def get_params
      params.require(:item).permit(permit_fields).merge(fix_params)
    end

  public
    # 新規登録
    def new
      @item = @model.new
    end

    # 入力確認
    def confirm
      @item = @model.new get_params
      @item.state = 'temporary'

      if @item.email_again.blank?
        @item.errors.add :email_again, I18n.t("errors.messages.not_input")
        render action: :new
        return
      end

      if @item.email != @item.email_again
        @item.errors.add :email, I18n.t("errors.messages.mismatch")
        render action: :new
        return
      end

      render action: :new unless @item.valid?
    end

    # 仮登録完了
    def interim
      @item = @model.new get_params
      @item.state = 'temporary'

      # 戻るボタンのクリック
      unless params[:submit]
        render action: :new
        return
      end

      render action: :new unless @item.save
    end

    # 確認メールのURLをクリック
    def verify
      @item = Cms::Member.site(@cur_site).where(verification_token: params[:token]).first

      unless @item.present?
        raise "404"
        return
      end
    end

    # 本登録
    def registration
      @item = Cms::Member.site(@cur_site).where(verification_token: params[:token]).first

      if params[:item][:in_password].blank?
        @item.errors.add :in_password, I18n.t("errors.messages.not_input")
        render action: :verify
        return
      end

      if params[:item][:in_password_again].blank?
        @item.errors.add :in_password_again, I18n.t("errors.messages.input_again")
        render action: :verify
        return
      end

      if params[:item][:in_password] != params[:item][:in_password_again]
        @item.errors.add :in_password, I18n.t("errors.messages.mismatch")
        render action: :verify
        return
      end

      @item.in_password = params[:item][:in_password]
      @item.encrypt_password
      @item.state = 'enabled'
      @item.verification_token = nil

      unless @item.update
        render action: :verify
        return
      end
    end

    def send_again
      @item = @model.new
    end

    def resend_confirmation_mail
      @item = @model.new get_params

      if @item.email.blank?
        @item.errors.add :email, I18n.t("errors.messages.not_input")
        render action: :send_again
        return
      end

      member = Cms::Member.site(@cur_site).where(email: @item.email).first
      if member.nil?
        @item.errors.add :email, I18n.t("errors.messages.not_registerd")
        render action: :send_again
        return
      end

      if member.authorized?
        @item.errors.add :email, I18n.t("errors.messages.already_registerd")
        render action: :send_again
        return
      end

      Member::Mailer.verification_mail(member).deliver_now

      redirect_to "#{@cur_node.url}send_again", notice: t("notice.resend_confirmation_mail")
    end

    # パスワード再設定
    def reset_password
      @item = Cms::Member.new
    end

    def confirm_reset_password
      @item = @model.new get_params

      if @item.email.blank?
        @item.errors.add :email, I18n.t("errors.messages.not_input")
        render action: :reset_password
        return
      end

      member = Cms::Member.site(@cur_site).and_enabled.where(email: @item.email).first
      if member.nil?
        @item.errors.add :email, I18n.t("errors.messages.not_registerd")
        render action: :reset_password
        return
      end

      Member::Mailer.reset_password_mail(member).deliver_now

      redirect_to "#{@cur_node.url}reset_password", notice: t("notice.send_reset_password_mail")
    end

    def change_password
      begin
        @item = Cms::Member.site(@cur_site).and_enabled.find_by_secure_id(params[:token])
      rescue Mongoid::Errors::DocumentNotFound =>e
        @item = nil
      end

      unless @item.present?
        raise "404"
        return
      end
    end

    def confirm_password
      begin
        @item = Cms::Member.site(@cur_site).and_enabled.find_by_secure_id(params[:token])
      rescue Mongoid::Errors::DocumentNotFound =>e
        raise "404"
        return
      end

      if params[:item][:new_password].blank?
        @item.errors.add I18n.t("member.view.new_password"), I18n.t("errors.messages.not_input")
        render action: :change_password
        return
      end

      if params[:item][:new_password_again].blank?
        @item.errors.add I18n.t("member.view.new_password_again"), I18n.t("errors.messages.not_input")
        render action: :change_password
        return
      end

      if params[:item][:new_password] != params[:item][:new_password_again]
        @item.errors.add I18n.t("member.view.new_password"), I18n.t("errors.messages.mismatch")
        render action: :change_password
        return
      end

      @item.in_password = params[:item][:new_password]
      @item.encrypt_password

      unless @item.update
        render :change_password
        return
      end

      redirect_to "#{@cur_node.url}reset_password", notice: t("notice.password_changed")
    end
end
