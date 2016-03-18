FactoryGirl.define do
  trait :cms_layout do
    site_id { cur_site ? cur_site.id : cms_site.id }
    user_id { cur_user ? cur_user.id : cms_user.id }
    name { unique_id.to_s }
    filename { "#{unique_id}.layout.html" }
    html { "<html><head></head><body></ yield /></body></html>" }
  end

  factory :cms_layout, class: Cms::Layout, traits: [:cms_layout] do
    #
  end
end
