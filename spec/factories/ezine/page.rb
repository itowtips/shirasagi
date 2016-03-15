FactoryGirl.define do
  factory :ezine_page, class: Ezine::Page, traits: [:cms_page] do
    route "ezine/page"
    name { unique_id }
    filename { "#{name}.html" }
    test_delivered nil
    completed false
  end
end
