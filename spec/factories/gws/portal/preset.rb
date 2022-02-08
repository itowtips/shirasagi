FactoryBot.define do
  factory :gws_portal_preset, class: Gws::Portal::Preset do
    cur_site { gws_site }
    cur_user { gws_user }
    name { unique_id }
  end
end
