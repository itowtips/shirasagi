FactoryBot.define do
  factory :ss_link_file, class: SS::LinkFile do
    cur_user { ss_user }
    model { "ss/#{unique_id}" }
    in_file { Fs::UploadedFile.create_from_file "#{Rails.root}/spec/fixtures/ss/logo.png", content_type: 'image/png' }
    link_url { "http://#{unique_id}.example.jp/" }
  end
end
