FactoryBot.define do
  factory :tourism_page, class: Tourism::Page, traits: [:cms_page] do
    route "tourism/page"
  end

  factory :tourism_notice, class: Tourism::Notice, traits: [:cms_page] do
    route "tourism/notice"
  end
end
