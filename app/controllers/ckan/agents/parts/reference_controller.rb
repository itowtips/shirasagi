class Ckan::Agents::Parts::ReferenceController < ApplicationController
  include Cms::PartFilter::View

  def index
    filename = @cur_main_path.sub(/\/[^\/]+?$/, "").sub(/^\//, "")

    @url = @cur_part.exporter.url
    @node = Cms::Node.site(@cur_site).where(filename: filename).first

    return unless @node

    if @node.route == "opendata/category" || @node.route == "opendata/estat_category"
      group_setting = @cur_part.exporter.group_settings.in(category_ids: @node.id).first
      if group_setting
        @url = ::File.join(@url, "group/#{group_setting.ckan_name}")
      else
        @url = ::File.join(@url, "dataset?q=#{@node.name}")
      end
    end
  end
end
