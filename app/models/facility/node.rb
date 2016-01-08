module Facility::Node
  class Base
    include Cms::Model::Node
    include Cms::Addon::NodeSetting

    default_scope ->{ where(route: /^facility\//) }
  end

  class Node
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::NodeList
    include Facility::Addon::CategorySetting
    include Facility::Addon::ServiceSetting
    include Facility::Addon::LocationSetting
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "facility/node") }
  end

  class Page
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Facility::Addon::Body
    include Cms::Addon::AdditionalInfo
    include Cms::Addon::AdditionalSecretInfo
    include Facility::Addon::SyncInstitution
    include Facility::Addon::Category
    include Facility::Addon::Service
    include Facility::Addon::Location
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup
    include ::Map::MapHelper

    def holiday_info
      additional_info.select { |i| i[:field] == "休業日" }.first
    end

    def open_hours_info
      additional_info.select do |i|
        i[:field] == "営業時間" || i[:field] == "サービス提供時間" || i[:field] == "診療時間（外来）" || i[:field] == "開局時間"
      end.first
    end

    def show_fax?
      categories.in(name: %w(医療機関 歯科)).count == 0
    end

    set_permission_name "facility_pages"

    default_scope ->{ where(route: "facility/page") }

    field :map_points, type: Array, default: []
    field :sidebar_html, type: String, default: ""
    before_save :set_map_points

    def serve_static_file?
      false
    end

    def set_map_points
      self.map_points = []

      category_ids = categories.map(&:id)
      image_id     = categories.map(&:image_id).first
      marker_info  = render_marker_info(self)
      self.sidebar_html = render_map_sidebar(self)

      Facility::Map.site(site).public.where(filename: /^#{filename}\//, depth: depth + 1).each do |item|
        item.map_points.each do |point|
          point[:category] = category_ids
          point[:image] = SS::File.find(image_id).url rescue nil
          point[:html] = marker_info
          point[:facility_id] = id

          self.map_points << point
        end
      end
    end
  end

  class Search
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Facility::Addon::CategorySetting
    include Facility::Addon::ServiceSetting
    include Facility::Addon::LocationSetting
    include Facility::Addon::SearchSetting
    include Facility::Addon::SearchResult
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "facility/search") }

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
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::NodeList
    include Facility::Addon::Image
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    #after_save :update_page_node
    default_scope ->{ where(route: "facility/category") }

    #def update_page_node
    #  Facility::Node::Page.in(category_ids: id).each(&:update)
    #end

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

  class Service
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::NodeList
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "facility/service") }

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
        cond << { :service_ids.in => cids } if cids.present?

        { '$or' => cond }
      end
  end

  class Location
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::NodeList
    include Facility::Addon::FocusSetting
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "facility/location") }

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
