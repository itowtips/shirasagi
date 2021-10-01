FactoryBot.define do
  factory :cms_line_template_text, class: Cms::Line::Template::Text do
    site { cms_site }
    text { unique_id }
  end
end
