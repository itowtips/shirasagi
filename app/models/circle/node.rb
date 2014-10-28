module Circle::Node
  class Base
    include Cms::Node::Model

    default_scope ->{ where(route: /^circle\//) }
  end

  class Node
    include Cms::Node::Model
    include Cms::Addon::NodeList
    include Circle::Addon::Category::Setting
    include Circle::Addon::Location::Setting

    default_scope ->{ where(route: "circle/node") }
  end

  class Page
    include Cms::Node::Model
    include Circle::Addon::Body
    include Circle::Addon::AdditionalInfo
    include Circle::Addon::Category::Category
    include Circle::Addon::Location::Location

    default_scope ->{ where(route: "circle/page") }
  end

  class Search
    include Cms::Node::Model
    include Cms::Addon::NodeList
    include Circle::Addon::Category::Setting
    include Circle::Addon::Location::Setting

    default_scope ->{ where(route: "circle/search") }

    public
      def condition_hash
        cond = []
        cids = []

        cond << {} if conditions.blank?
        conditions.each do |url|
          node = Cms::Node.filename(url).first
          next unless node
          cond << { filename: /^#{node.filename}\//, depth: node.depth + 1 }
          cids << node.id
        end
        cond << { :category_ids.in => cids } if cids.present?

        { '$or' => cond }
      end
  end

  class Category
    include Cms::Node::Model
    include Cms::Addon::NodeList

    default_scope ->{ where(route: "circle/category") }
  end

  class Location
    include Cms::Node::Model
    include Cms::Addon::NodeList

    default_scope ->{ where(route: "circle/location") }
  end
end
