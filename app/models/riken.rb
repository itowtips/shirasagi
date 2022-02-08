module Riken
  PASSWORD = begin
    password = SS.config.credentials.riken["password"]
    [ password ].pack("H*").freeze
  end
  SALT = begin
    salt = SS.config.credentials.riken["salt"]
    [ salt ].pack("H*").freeze
  end
  CIPHER_TYPE = "AES-256-CBC".freeze

  def self.encrypt(plain)
    return plain if plain.blank?

    cipher = OpenSSL::Cipher.new(CIPHER_TYPE)
    cipher.encrypt

    key_iv = OpenSSL::PKCS5.pbkdf2_hmac(PASSWORD, SALT, 2000, cipher.key_len + cipher.iv_len, 'sha256')
    cipher.key = key_iv[0, cipher.key_len]
    cipher.iv = key_iv[cipher.key_len, cipher.iv_len]

    encrypted = cipher.update(plain) + cipher.final
    encrypted.unpack1("H*")
  end

  def self.decrypt(encrypted)
    return encrypted if encrypted.blank?

    cipher = OpenSSL::Cipher.new(CIPHER_TYPE)
    cipher.decrypt

    key_iv = OpenSSL::PKCS5.pbkdf2_hmac(PASSWORD, SALT, 2000, cipher.key_len + cipher.iv_len, 'sha256')
    cipher.key = key_iv[0, cipher.key_len]
    cipher.iv = key_iv[cipher.key_len, cipher.iv_len]

    encrypted = [ encrypted ].pack("H*")
    plain = cipher.update(encrypted) + cipher.final
    plain.force_encoding(Encoding.default_internal)
    plain
  end
end
