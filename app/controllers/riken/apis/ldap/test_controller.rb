class Riken::Apis::Ldap::TestController < ApplicationController
  include Gws::ApiFilter

  def connection
    errors = []
    safe_params = params.require(:item).permit(
      :riken_ldap_url, :riken_ldap_bind_dn, :in_riken_ldap_bind_password
    )
    if safe_params[:riken_ldap_url].blank?
      errors << t("errors.format", attribute: Gws::Group.t(:riken_ldap_url), message: t("errors.messages.blank"))
    end
    if safe_params[:riken_ldap_bind_dn].blank?
      errors << t("errors.format", attribute: Gws::Group.t(:riken_ldap_bind_dn), message: t("errors.messages.blank"))
    end

    @cur_site.riken_ldap_url = safe_params[:riken_ldap_url]
    @cur_site.riken_ldap_bind_dn = safe_params[:riken_ldap_bind_dn]
    if safe_params[:in_riken_ldap_bind_password].present?
      @cur_site.riken_ldap_bind_password = Riken.encrypt(safe_params[:in_riken_ldap_bind_password])
    end

    @cur_site.riken_ldap_connection!

    message = "success"
    render json: { status: errors.blank? ? "ok" : "error", errors: errors, results: [ message ] }
  rescue => e
    logger.info("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    errors << e.to_s
    render json: { status: "error", errors: errors }
  end

  def group_search
    errors = []
    safe_params = params.require(:item).permit(
      :riken_ldap_url, :riken_ldap_bind_dn, :in_riken_ldap_bind_password,
      :riken_ldap_group_dn, :riken_ldap_group_filter
    )
    if safe_params[:riken_ldap_url].blank?
      errors << t("errors.format", attribute: Gws::Group.t(:riken_ldap_url), message: t("errors.messages.blank"))
    end
    if safe_params[:riken_ldap_bind_dn].blank?
      errors << t("errors.format", attribute: Gws::Group.t(:riken_ldap_bind_dn), message: t("errors.messages.blank"))
    end

    @cur_site.riken_ldap_url = safe_params[:riken_ldap_url]
    @cur_site.riken_ldap_bind_dn = safe_params[:riken_ldap_bind_dn]
    if safe_params[:in_riken_ldap_bind_password].present?
      @cur_site.riken_ldap_bind_password = Riken.encrypt(safe_params[:in_riken_ldap_bind_password])
    end

    connection = @cur_site.riken_ldap_connection!
    filter = safe_params[:riken_ldap_group_filter].presence || Riken::Ldap::GROUP_FILTER
    filter = Net::LDAP::Filter.construct(filter)
    base_dn = safe_params[:riken_ldap_group_dn].presence || Riken::Ldap::GROUP_BASE_DN
    result = connection.search(filter: filter, base: base_dn)

    message = "found #{result.length.to_s(:delimited)} entries"
    render json: { status: errors.blank? ? "ok" : "error", errors: errors, results: [ message ] }
  rescue => e
    logger.info("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    errors << e.to_s
    render json: { status: "error", errors: errors }
  end

  def user_search
    errors = []
    safe_params = params.require(:item).permit(
      :riken_ldap_url, :riken_ldap_bind_dn, :in_riken_ldap_bind_password,
      :riken_ldap_user_dn, :riken_ldap_user_filter
    )
    if safe_params[:riken_ldap_url].blank?
      errors << t("errors.format", attribute: Gws::Group.t(:riken_ldap_url), message: t("errors.messages.blank"))
    end
    if safe_params[:riken_ldap_bind_dn].blank?
      errors << t("errors.format", attribute: Gws::Group.t(:riken_ldap_bind_dn), message: t("errors.messages.blank"))
    end

    @cur_site.riken_ldap_url = safe_params[:riken_ldap_url]
    @cur_site.riken_ldap_bind_dn = safe_params[:riken_ldap_bind_dn]
    if safe_params[:in_riken_ldap_bind_password].present?
      @cur_site.riken_ldap_bind_password = Riken.encrypt(safe_params[:in_riken_ldap_bind_password])
    end

    connection = @cur_site.riken_ldap_connection!
    filter = safe_params[:riken_ldap_user_filter].presence || Riken::Ldap::USER_FILTER
    filter = Net::LDAP::Filter.construct(filter)
    base_dn = safe_params[:riken_ldap_user_dn].presence || Riken::Ldap::USER_BASE_DN
    result = connection.search(filter: filter, base: base_dn)

    message = "found #{result.length.to_s(:delimited)} entries"
    render json: { status: errors.blank? ? "ok" : "error", errors: errors, results: [ message ] }
  rescue => e
    logger.info("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    errors << e.to_s
    render json: { status: "error", errors: errors }
  end

  def custom_group_search
    index = params[:index]
    raise "404" if !index.numeric?

    index = index.to_i

    safe_params = params.require(:item).permit(
      :riken_ldap_url, :riken_ldap_bind_dn, :in_riken_ldap_bind_password,
      riken_ldap_custom_group_conditions: [ :name, :dn, :filter ]
    )

    @cur_site.riken_ldap_url = safe_params[:riken_ldap_url]
    @cur_site.riken_ldap_bind_dn = safe_params[:riken_ldap_bind_dn]
    if safe_params[:in_riken_ldap_bind_password].present?
      @cur_site.riken_ldap_bind_password = Riken.encrypt(safe_params[:in_riken_ldap_bind_password])
    end

    errors = []

    connection = @cur_site.riken_ldap_connection!
    base_dn = safe_params[:riken_ldap_custom_group_conditions][index][:dn]
    if base_dn.blank?
      errors << t("errors.format", attribute: "DN", message: t("errors.messages.blank"))
    end

    filter = safe_params[:riken_ldap_custom_group_conditions][index][:filter]
    if filter.blank?
      errors << t("errors.format", attribute: "Filter", message: t("errors.messages.blank"))
    end

    if errors.present?
      render json: { status: "error", errors: errors }
      return
    end

    result = connection.search(filter: filter, base: base_dn)
    message = "found #{result.length.to_s(:delimited)} entries"
    render json: { status: errors.blank? ? "ok" : "error", errors: errors, results: [ message ] }
  rescue => e
    logger.info("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    errors << e.to_s
    render json: { status: "error", errors: errors }
  end
end
