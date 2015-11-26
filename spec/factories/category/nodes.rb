FactoryGirl.define do
  factory :category_node_base, class: Category::Node::Base, traits: [:cms_node] do
    transient do
      site nil
      node nil
    end

    cur_site { site ? site : cms_site }
    filename { node ? "#{node.filename}/#{unique_id}" : "#{unique_id}" }
    depth { node ? node.depth + 1 : 1 }
    route "category/base"
  end

  factory :category_node_node, class: Category::Node::Node, traits: [:cms_node] do
    transient do
      site nil
      node nil
    end

    cur_site { site ? site : cms_site }
    filename { node ? "#{node.filename}/#{unique_id}" : "#{unique_id}" }
    depth { node ? node.depth + 1 : 1 }
    route "category/node"
  end

  factory :category_node_page, class: Category::Node::Page, traits: [:cms_node] do
    transient do
      site nil
      node nil
    end

    cur_site { site ? site : cms_site }
    filename { node ? "#{node.filename}/#{unique_id}" : "#{unique_id}" }
    depth { node ? node.depth + 1 : 1 }
    route "category/page"
  end
end
