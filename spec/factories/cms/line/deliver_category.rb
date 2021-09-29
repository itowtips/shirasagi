FactoryBot.define do
  factory :cms_line_deliver_category, class: Cms::Line::DeliverCategory do
    site { cms_site }
    name { unique_id }
  end
end
