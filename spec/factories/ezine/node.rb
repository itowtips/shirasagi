FactoryGirl.define do
  factory :ezine_node, class: Ezine::Node::Page do
    cur_site { cms_site }
    cur_user { cms_user }
    name { unique_id }
    filename { unique_id }
    route 'ezine/page'
  end
end
