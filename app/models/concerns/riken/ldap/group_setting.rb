require 'net/ldap'
require 'net/ldap/dn'
require 'uri'

module Riken::Ldap::GroupSetting
  extend ActiveSupport::Concern

  MAX_LDAP_CUSTOM_GROUP_CONDITIONS = 10

  included do
    field :riken_ldap_url, type: String
    field :riken_ldap_bind_dn, type: String
    field :riken_ldap_bind_password, type: String
    field :riken_ldap_group_dn, type: String
    field :riken_ldap_group_filter, type: String
    field :riken_ldap_user_dn, type: String
    field :riken_ldap_user_filter, type: String
    embeds_ids :riken_ldap_sys_roles, class_name: "Sys::Role"
    embeds_ids :riken_ldap_gws_roles, class_name: "Gws::Role"

    field :riken_ldap_custom_group_conditions, type: Riken::Extensions::Ldap::CustomGroupConditions

    attr_accessor :in_riken_ldap_bind_password, :rm_riken_ldap_bind_password

    permit_params :riken_ldap_url, :riken_ldap_bind_dn
    permit_params :in_riken_ldap_bind_password, :rm_riken_ldap_bind_password
    permit_params :riken_ldap_group_dn, :riken_ldap_group_filter
    permit_params :riken_ldap_user_dn, :riken_ldap_user_filter
    permit_params riken_ldap_sys_role_ids: [], riken_ldap_gws_role_ids: []
    permit_params riken_ldap_custom_group_conditions: [ :name, :dn, :filter ]

    before_validation :encrypt_riken_ldap_bind_password

    validates :riken_ldap_url, url: { scheme: %w(ldap ldaps) }
    validates :riken_ldap_custom_group_conditions, length: { maximum: MAX_LDAP_CUSTOM_GROUP_CONDITIONS }
    validate :validate_riken_ldap_dns
    validate :validate_riken_ldap_filters
  end

  def riken_ldap_connection!
    url = Addressable::URI.parse(riken_ldap_url)
    host = url.host
    port = url.port || (url.scheme == 'ldaps' ? URI::LDAPS::DEFAULT_PORT : URI::LDAP::DEFAULT_PORT)

    config = { host: host, port: port }
    config[:encryption] = :simple_tls if url.scheme == 'ldaps'
    config[:auth] = {
      method: :simple,
      username: riken_ldap_bind_dn,
      password: Riken.decrypt(riken_ldap_bind_password)
    }

    connection = Net::LDAP.new(config)
    raise "ldap bind failed" unless connection.bind

    connection
  end

  private

  def encrypt_riken_ldap_bind_password
    if in_riken_ldap_bind_password.present?
      self.riken_ldap_bind_password = Riken.encrypt(in_riken_ldap_bind_password)
      return
    end

    if rm_riken_ldap_bind_password == "1"
      self.riken_ldap_bind_password = nil
    end
  end

  def validate_riken_ldap_dns
    %i[riken_ldap_bind_dn riken_ldap_group_dn riken_ldap_user_dn].each do |dn_field|
      dn = send(dn_field)
      if dn.present?
        Net::LDAP::DN.new(dn).to_a
      end
    rescue => e
      Rails.logger.info { "#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}" }
      errors.add dn_field, :invalid
    end
  end

  def validate_riken_ldap_filters
    %i[riken_ldap_group_filter riken_ldap_user_filter].each do |filter_field|
      filter = send(filter_field)
      if filter.present?
        Net::LDAP::Filter.construct(filter)
      end
    rescue => e
      Rails.logger.info { "#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}" }
      errors.add filter_field, :invalid
    end
  end
end
