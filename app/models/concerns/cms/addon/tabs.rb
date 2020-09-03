module Cms::Addon
  module Tabs
    extend ActiveSupport::Concern
    extend SS::Addon

    attr_accessor :cur_date

    included do
      field :conditions, type: SS::Extensions::Words
      field :limit, type: Integer, default: 8
      field :loop_html, type: String
      field :new_days, type: Integer, default: 1
      field :loop_format, type: String
      field :loop_liquid, type: String

      permit_params :conditions, :limit, :new_days
      permit_params :loop_html, :loop_format, :loop_liquid

      before_validation :validate_conditions
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
      date + new_days > Time.zone.now
    end

    def loop_format_options
      %w(shirasagi liquid).map do |v|
        [ I18n.t("cms.options.loop_format.#{v}"), v ]
      end
    end

    def upper_html
      nil
    end

    def lower_html
      nil
    end

    def loop_format_liquid?
      loop_format == "liquid"
    end

    def loop_format_shirasagi?
      !loop_format_liquid?
    end

    def loop_setting
      nil
    end

    def render_loop_html(item, opts = {})
      item = item.becomes_with_route rescue item
      item.render_template(opts[:html] || loop_html, self)
    end

    private

    def validate_conditions
      self.conditions = conditions.map do |m|
        m.strip.sub(/^\w+:\/\/.*?\//, "").sub(/^\//, "").sub(/\/$/, "")
      end.compact.uniq
    end
  end
end
