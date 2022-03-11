FactoryBot.define do
  factory :riken_payment_importer_setting, class: Riken::Payment::ImporterSetting do
    cur_site { gws_site }

    # circular
    api_url { "https://riken.example.jp/workflows" }
    request_title { unique_id }
    remand_title { unique_id }
    circular_owner { gws_user }

    # oauth
    token_url { "https://riken.example.jp/token" }
    client_id { unique_id }
    in_private_key { OpenSSL::PKey::RSA.generate(2048).to_s }
    sub { gws_user.uid }
    scope { "edit_other_gws_circular_posts" }
    aud { "https://riken.example.jp/token" }
  end
end
