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

    set_permission_name "facility_pages"

    default_scope ->{ where(route: "facility/page") }

    field :map_points, type: Array, default: []
    field :sidebar_html, type: String, default: ""
    field :images, type: Array, default: []
    field :map_points, type: Array, default: []
    before_save :set_map_points
    before_save :set_images
    before_save :send_notice_mail

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
    
    def set_images
      self.images = []

      Facility::Image.site(site).public.where(filename: /^#{filename}\//, depth: depth + 1).each do |item|
        if item.image
          self.images << item.image.id
        end
      end
    end
    
    def send_notice_mail
      cms_site = Cms::Site.find(site.id)    
      return unless cms_site.notice_mail_enabled?
      
      ins_was = self.class.where(id: id).first
      ins = self
      mail_send = false
      fields = []
      
      notice_fields = %w(
        route name filename depth layout_id
        page_layout_id order shortcut view_route 
        keywords description summary_html
        kana postcode address tel email fax related_url
        additional_info
        additional_secret_info
        category_ids
        service_ids
        location_ids
        state released
        group_ids permission_level
        map_points
        images
        )

      if ins_was.nil?
        mail_send = true
      else
        attr = ins.attributes.select { |k, v| notice_fields.index(k) }
        attr_was = ins_was.attributes.select { |k, v| notice_fields.index(k) }
        mail_send = true if attr != attr_was
        
        attr.each do |k,v|
          v_was = attr_was[k]
          
          if k == "map_points"
            v = v.map{|item| item["loc"]}
            v_was = v_was.map{|item| item["loc"]}
          end

          if v != v_was
            fields << self.t(k)
          end
        end
      end
      
      if cur_user && mail_send
        Facility::Mailer.update_mail(cms_site.from_mail, cms_site.notice_mail, self, fields.join(", ")).deliver_now
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
