module Pippi::Member::MypageSetting
  extend ActiveSupport::Concern
  include Cms::Addon::List::Model

  module ClassMethods
    def define_list(name)
      Proc.new do
        field "#{name}_conditions", type: SS::Extensions::Words
        field "#{name}_limit", type: Integer, default: 4
        field "#{name}_loop_html", type: String
        field "#{name}_upper_html", type: String
        field "#{name}_lower_html", type: String
        field "#{name}_loop_format", type: String
        field "#{name}_loop_liquid", type: String
        field "#{name}_no_items_display_state", type: String
        field "#{name}_substitute_html", type: String
        permit_params "#{name}_conditions", "#{name}_limit"
        permit_params "#{name}_loop_html", "#{name}_upper_html", "#{name}_lower_html"
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
        define_method("#{name}_context") do
          context = OpenStruct.new(
            limit: send("#{name}_limit"),
            loop_html: send("#{name}_loop_html"),
            upper_html: send("#{name}_upper_html"),
            lower_html: send("#{name}_lower_html"),
            loop_format: send("#{name}_loop_format"),
            loop_liquid: send("#{name}_loop_liquid"),
            no_items_display_state: send("#{name}_no_items_display_state"),
            substitute_html: send("#{name}_substitute_html"),
            conditions: send("#{name}_conditions")
          )
          context
        end
      end
    end
  end
end
