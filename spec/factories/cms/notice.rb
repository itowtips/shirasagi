FactoryGirl.define do
  factory :cms_notice, class: Cms::Notice do
    cur_site { cms_site }
    name { "name-#{unique_id}" }
  end
end
