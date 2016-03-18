FactoryGirl.define do
  factory :cms_body_layout, class: Cms::BodyLayout do
    site_id { cur_site ? cur_site.id : cms_site.id }
    user_id { cur_user ? cur_user.id : cms_user.id }
    name "body_layout"
    filename { "#{name}.layout.html" }
    parts { %w(part1 part2 part3) }
    html do
      '<div><p class="yield0">{{ yield 0 }}</p><p class="yield1">{{ yield 1 }}</p><p class="yield2">{{ yield 2 }}</p></div>'
    end
  end
end
