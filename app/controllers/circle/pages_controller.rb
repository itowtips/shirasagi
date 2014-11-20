class Circle::PagesController < ApplicationController
  include Cms::BaseFilter
  include Cms::NodeFilter

  model Circle::Node::Page

  prepend_view_path "app/views/cms/node/nodes"
  menu_view "circle/page/menu"

  private
    def fix_params
      { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node }
    end

    def pre_params
      { route: "circle/page" }
    end

    def map_pages
      Circle::Map.site(@cur_site).public.
        where(filename: /^#{@item.filename}\//, depth: @item.depth + 1).order_by(order: -1)
    end

    def image_pages
      Circle::Image.site(@cur_site).public.
        where(filename: /^#{@item.filename}\//, depth: @item.depth + 1).order_by(order: -1)
    end

  public
    def index
      @items = @model.site(@cur_site).node(@cur_node).
        allow(:read, @cur_user).
        order_by(filename: 1).
        page(params[:page]).per(50)
    end

    def show
      raise "403" unless @item.allowed?(:read, @cur_user)

      @maps = map_pages
      @maps.each do |map|
        points = []
        map.map_points.each_with_index do |point, i|
          points.push point

          image_ids = @item.categories.pluck(:image_id)
          points[i][:pointer_image] = Circle::TempFile.find(image_ids.first).url if image_ids.present?
        end
        map.map_points = points

        if @merged_map
          @merged_map.map_points += map.map_points
        else
          @merged_map = map
        end
      end

      @summary_image = nil
      @images = []
      image_pages.each do |page|
        next if page.image.blank?

        if @summary_image
          @images.push page
        else
          @summary_image = page
        end
      end
    end
end
