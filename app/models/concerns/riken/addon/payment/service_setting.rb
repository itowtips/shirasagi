module Riken::Addon::Payment::ServiceSetting
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    attr_accessor :in_private_key
    attr_reader :access_token

    field :token_url, type: String
    field :client_id, type: String
    field :private_key_type, type: String
    field :private_key_encrypted, type: String

    field :sub, type: String
    field :scope, type: String
    field :aud, type: String

    before_validation :encrypt_private_key
    validates :token_url, presence: true
    validates :client_id, presence: true
    validates :sub, presence: true
    validates :scope, presence: true
    validates :aud, presence: true
    validates :private_key_encrypted, presence: true

    permit_params :token_url, :client_id, :in_private_key
    permit_params :sub, :scope, :aud
  end

  def private_key
    private_key = SS::Crypt.decrypt(private_key_encrypted)
    OpenSSL::PKey::RSA.new(private_key)
  end

  def private_key_finger_print
    return nil if private_key_encrypted.blank?
    OpenSSL::Digest::SHA1.hexdigest(private_key.to_der).scan(/../).join(':')
  end

  def get_access_token
    @access_token = nil

    now = Time.zone.now
    uri = ::Addressable::URI.parse(token_url)
    path = uri.path
    base_url = uri.to_s.sub(path, "")
    payload = {
      iss: client_id,
      sub: sub,
      scope: scope,
      aud: aud,
      exp: now.to_i + 3600,
      iat: now.to_i
    }
    token = JWT.encode(payload, private_key, 'RS256')
    conn = Faraday.new(
      url: base_url,
      headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
    )
    params = {
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: token
    }
    response = conn.post(path) do |req|
      req.body = params.to_query
    end
    res_json = ::JSON.parse(response.body)
    token = res_json["access_token"]
    raise "failed to get access_token : #{res_json}" if token.blank?
    @access_token = token
  end

  def get_payment_workflows
    uri = ::Addressable::URI.parse(api_url)
    path = uri.path
    base_url = uri.to_s.sub(path, "")

    headers = {}
    headers['Content-Type'] = 'application/json'
    headers['Authorization'] = "Bearer #{access_token}" if access_token.present?

    client = Faraday.new(url: base_url, headers: headers)
    response = client.post(path)
    JSON.parse(response.body)
  end

  private

  def encrypt_private_key
    return if in_private_key.blank?

    begin
      key = OpenSSL::PKey::RSA.new(in_private_key) do
        nil
      end
    rescue OpenSSL::OpenSSLError => e
      Rails.logger.info("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    end
    return if key.blank?

    self.private_key_type = "rsa"
    self.private_key_encrypted = SS::Crypt.encrypt(key.to_pem)
  end
end
