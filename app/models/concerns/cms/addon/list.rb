module Cms::Addon::List
  module Model
    extend ActiveSupport::Concern
    extend SS::Translation

    attr_accessor :cur_date

    included do
      field :conditions, type: SS::Extensions::Words
      field :sort, type: String
      field :limit, type: Integer, default: 20
      field :loop_html, type: String
      field :upper_html, type: String
      field :lower_html, type: String
      field :new_days, type: Integer, default: 1
      permit_params :conditions, :sort, :limit, :loop_html, :upper_html, :lower_html, :new_days

      before_validation :validate_conditions

      template_variable_handler :name, :template_variable_handler_name
      template_variable_handler :url, :template_variable_handler_name
      template_variable_handler :summary, :template_variable_handler_name
      template_variable_handler :class, :template_variable_handler_class
      template_variable_handler :new, :template_variable_handler_new
      template_variable_handler :date, :template_variable_handler_date
      template_variable_handler /^date\.(\w+)$/, :template_variable_handler_date2
      template_variable_handler :time, :template_variable_handler_time
      template_variable_handler /^time\.(\w+)$/, :template_variable_handler_time2
      template_variable_handler :group, :template_variable_handler_group
      template_variable_handler :groups, :template_variable_handler_groups
      template_variable_handler "img.src", :template_variable_handler_img_src
      template_variable_handler :categories, :template_variable_handler_categories
      template_variable_handler "pages.count", :template_variable_handler_pages_count
    end

    module ClassMethods
      def template_variable_handlers
        instance_variable_get(:@_template_variable_handlers) || []
      end

      def template_variable_handlers=(value)
        instance_variable_set(:@_template_variable_handlers, value)
      end

      def template_variable_handler(name, proc, &block)
        handlers = template_variable_handlers

        name = name.to_sym if name.respond_to?(:to_sym)
        handlers << [name, proc || block]
        self.template_variable_handlers = handlers
      end
    end

    def sort_options
      []
    end

    def sort_hash
      {}
    end

    def limit
      value = self[:limit].to_i
      (value < 1 || 1000 < value) ? 100 : value
    end

    def new_days
      value = self[:new_days].to_i
      (value < 0 || 30 < value) ? 30 : value
    end

    def in_new_days?(date)
      date + new_days > (@cur_date || Time.zone.now)
    end

    def condition_hash(opts = {})
      cond = []
      cids = []
      cond_url = []

      if opts[:cur_path] && conditions.index('#{request_dir}')
        cur_dir = opts[:cur_path].sub(/\/[\w\-\.]*?$/, "").sub(/^\//, "")
        cond_url = conditions.map {|url| url.sub('#{request_dir}', cur_dir)}
      else
        if self.is_a?(Cms::Model::Part)
          if parent
            cond << { filename: /^#{parent.filename}\//, depth: depth }
            cids << parent.id
          else
            cond << { depth: depth }
          end
        else
          cond << { filename: /^#{filename}\//, depth: depth + 1 }
          cids << id
        end
        cond_url = conditions
      end

      cond_url.each do |url|
        # regex
        if url =~ /\/\*$/
          filename = url.sub(/\/\*$/, "")
          cond << { filename: /^#{filename}\// }
          next
        end

        node = Cms::Node.filename(url).first
        next unless node

        cond << { filename: /^#{node.filename}\//, depth: node.depth + 1 }
        cids << node.id
      end
      cond << { :category_ids.in => cids } if cids.present?
      cond << { :id => -1 } if cond.blank?

      { '$or' => cond }
    end

    def render_loop_html(item, opts = {})
      item = item.becomes_with_route rescue item
      (opts[:html] || loop_html).gsub(/\#\{(.*?)\}/) do |m|
        str = template_variable_get(item, $1) rescue false
        str == false ? m : str
      end
    end

    def template_variable_get(item, name)
      name_sym = name.to_sym
      _, proc = self.class.template_variable_handlers.find do |n, _|
        if n.is_a?(Symbol)
          n == name_sym
        elsif n.is_a?(Regexp)
          n =~ name
        else
          false
        end
      end

      return false if proc.nil?

      proc = method(proc) if proc.is_a?(Symbol)
      proc.call(item, name)
    end

    private
      def validate_conditions
        self.conditions = conditions.map do |m|
          m.strip.sub(/^\w+:\/\/.*?\//, "").sub(/^\//, "").sub(/\/$/, "")
        end.compact.uniq
      end

      def template_variable_handler_name(item, name)
        ERB::Util.html_escape item.send(name)
      end

      def template_variable_handler_class(item, name)
        item.basename.sub(/\..*/, "").dasherize
      end

      def template_variable_handler_new(item, name)
        respond_to?(:in_new_days?) && in_new_days?(item.date) ? "new" : nil
      end

      def template_variable_handler_date(item, name)
        I18n.l item.date.to_date
      end

      def template_variable_handler_date2(item, name)
        format = name.split('.').last
        I18n.l item.date.to_date, format: format.to_sym
      end

      def template_variable_handler_time(item, name)
        I18n.l item.date
      end

      def template_variable_handler_time2(item, name)
        format = name.split('.').last
        I18n.l item.date, format: format.to_sym
      end

      def template_variable_handler_group(item, name)
        group = item.groups.first
        group ? group.name.split(/\//).pop : ""
      end

      def template_variable_handler_groups(item, name)
        item.groups.map { |g| g.name.split(/\//).pop }.join(", ")
      end

      def template_variable_handler_img_src(item, name)
        dummy_source = ERB::Util.html_escape("/assets/img/dummy.gif")

        return dummy_source unless item.respond_to?(:html)
        return dummy_source unless item.html =~ /\<\s*?img\s+[^>]*\/?>/i

        img_tag = $&
        return dummy_source unless img_tag =~ /src\s*=\s*(['"]?[^'"]+['"]?)/

        img_source = $1
        img_source = img_source[1..-1] if img_source.start_with?("'") || img_source.start_with?('"')
        img_source = img_source[0..-2] if img_source.end_with?("'") || img_source.end_with?('"')
        img_source = img_source.strip
        if img_source.start_with?('.')
          img_source = File.dirname(item.url) + '/' + img_source
        end
        img_source
      end

      def template_variable_handler_categories(item, name)
        # 記事ページに設定されているカテゴリのリスト（CSS で調整しやすいようにある程度構造化した形で出す）
        # <span class="#{filename}"><a href="....">#{name}</a></span>
        # <span class="#{filename}"><a href="....">#{name}</a></span>
        return nil unless categories = item.try(:categories)

        ret = categories.map do |category|
          "<span class=\"#{category.filename.gsub('/', '-')}\"><a href=\"#{category.url}\">#{ERB::Util.html_escape(category.name)}</a></span>"
        end
        ret.join("\n").html_safe
      end

      def template_variable_handler_pages_count(item, name)
        Cms::Page.site(item.site).and_public(@cur_date || Time.zone.now).or({ filename: /^#{item.filename}\//, depth: item.depth + 1 }, { category_ids: item.id }).count.to_s
      rescue
        nil
      end
  end
end
