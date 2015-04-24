module Circle::Node
  class Base
    include Cms::Model::Node

    default_scope ->{ where(route: /^circle\//) }
  end

  class Node
    include Cms::Model::Node
    include Cms::Addon::NodeList
    include Cms::Addon::Meta
    include Circle::Addon::CategorySetting
    include Circle::Addon::LocationSetting

    default_scope ->{ where(route: "circle/node") }
  end

  class Page
    include Cms::Model::Node
    include Cms::Addon::Meta
    include Circle::Addon::Body
    include Cms::Addon::AdditionalInfo
    include Circle::Addon::Category
    include Circle::Addon::Location

    default_scope ->{ where(route: "circle/page") }
  end

  class Search
    include Cms::Model::Node
    include Cms::Addon::NodeList
    include Cms::Addon::Meta
    include Circle::Addon::CategorySetting
    include Circle::Addon::LocationSetting

    default_scope ->{ where(route: "circle/search") }

    public
      def condition_hash
        cond = []

        cond << { filename: /^#{filename}\// } if conditions.blank?
        conditions.each do |url|
          node = Cms::Node.filename(url).first
          next unless node
          cond << { filename: /^#{node.filename}\//, depth: node.depth + 1 }
        end

        { '$or' => cond }
      end
  end

  class Category
    include Cms::Model::Node
    include Cms::Addon::NodeList
    include Cms::Addon::Meta

    default_scope ->{ where(route: "circle/category") }

    public
      def condition_hash
        cond = []
        cids = []

        cids << id
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

  class Location
    include Cms::Model::Node
    include Cms::Addon::NodeList
    include Cms::Addon::Meta

    default_scope ->{ where(route: "circle/location") }

    public
      def condition_hash
        cond = []
        cids = []

        cids << id
        conditions.each do |url|
          node = Cms::Node.filename(url).first
          next unless node
          cond << { filename: /^#{node.filename}\//, depth: node.depth + 1 }
          cids << node.id
        end
        cond << { :location_ids.in => cids } if cids.present?

        { '$or' => cond }
      end
  end
end
