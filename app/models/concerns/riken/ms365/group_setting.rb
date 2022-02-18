module Riken::MS365::GroupSetting
  extend ActiveSupport::Concern
  extend SS::Translation

  included do
    field :riken_ms365_tenant_id, type: String
    field :riken_ms365_client_id, type: String
    field :riken_ms365_client_secret, type: String

    attr_accessor :in_riken_ms365_client_secret, :rm_riken_ms365_client_secret

    permit_params :riken_ms365_tenant_id, :riken_ms365_client_id
    permit_params :in_riken_ms365_client_secret, :rm_riken_ms365_client_secret

    before_validation :encrypt_riken_ms365_client_secret
  end

  private

  def encrypt_riken_ms365_client_secret
    if in_riken_ms365_client_secret.present?
      self.riken_ms365_client_secret = Riken.encrypt(in_riken_ms365_client_secret)
      return
    end

    if rm_riken_ms365_client_secret == "1"
      self.riken_ms365_client_secret = nil
    end
  end
end
