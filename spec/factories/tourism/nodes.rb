FactoryBot.define do
  factory :tourism_node_base, class: Tourism::Node::Base, traits: [:cms_node] do
    route "tourism/base"
  end

  factory :tourism_node_page, class: Tourism::Node::Page, traits: [:cms_node] do
    route "tourism/page"
  end

  factory :tourism_node_notice, class: Tourism::Node::Notice, traits: [:cms_node] do
    route "tourism/notice"
  end

  factory :tourism_node_map, class: Tourism::Node::Map, traits: [:cms_node] do
    route "tourism/map"
  end
end
