module Pippi::Member::MypageSetting
  extend ActiveSupport::Concern

  def loop_delegates
    []
  end

  module ClassMethods
    def define_list(name)
      Proc.new do
        field "#{name}_limit", type: Integer, default: 4
        field "#{name}_loop_html", type: String
        field "#{name}_upper_html", type: String
        field "#{name}_lower_html", type: String
        field "#{name}_loop_format", type: String
        field "#{name}_loop_liquid", type: String
        field "#{name}_no_items_display_state", type: String
        field "#{name}_substitute_html", type: String
        permit_params "#{name}_limit", "#{name}_loop_html", "#{name}_upper_html", "#{name}_lower_html"
        permit_params "#{name}_loop_format", "#{name}_loop_liquid"
        permit_params "#{name}_no_items_display_state", "#{name}_substitute_html"

        define_method("#{name}_loop_format_options") do
          %w(shirasagi liquid).map do |v|
            [ I18n.t("cms.options.loop_format.#{v}"), v ]
          end
        end
        define_method("#{name}_no_items_display_state_options") do
          %w(show hide).map { |v| [ I18n.t("ss.options.state.#{v}"), v ] }
        end
        define_method("#{name}_loop_format_liquid?") do
          send("#{name}_loop_format") == "liquid"
        end
        define_method("#{name}_loop_format_shirasagi?") do
          !send("#{name}_loop_format_liquid?")
        end
        define_method("child_#{name}_node") do
          node = children.where(depth: (depth + 1), filename: /\/#{name}$/).first
          node.try(:becomes_with_route)
        end
        #define_method("#{name}_criteria_proc") do
        #  proc { |context| [] }
        #end
        define_method("#{name}_loop_delegate") do
          node = send("child_#{name}_node")
          return unless node
          OpenStruct.new(
            node: node,
            criteria_proc: send("#{name}_criteria_proc"),
            attributes: {
              limit: send("#{name}_limit"),
              loop_html: send("#{name}_loop_html"),
              upper_html: send("#{name}_upper_html"),
              lower_html: send("#{name}_lower_html"),
              loop_format: send("#{name}_loop_format"),
              loop_liquid: send("#{name}_loop_liquid"),
              no_items_display_state: send("#{name}_no_items_display_state"),
              substitute_html: send("#{name}_substitute_html"),
            }
          )
        end
      end
    end
  end
end
