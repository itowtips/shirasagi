class Facility::Agents::Nodes::SearchController < ApplicationController
  include Cms::NodeFilter::View
  helper Cms::ListHelper
  helper Map::MapHelper

  before_action :short_url

  private
    def short_url
      cond = { site_id: @cur_site.id, url: request.url }

      item = Cms::ShortUrl.find_or_create_by(cond)
      redirect_to "#{@cur_site.url}short/#{item.id}"
    end

    def set_items
      @category_ids = params[:category_ids].select(&:present?).map(&:to_i) rescue nil
      @service_ids  = params[:service_ids].select(&:present?).map(&:to_i) rescue nil
      @location_ids = params[:location_ids].select(&:present?).map(&:to_i) rescue nil

      q_category = @category_ids.present? ? { category_ids: @category_ids } : {}
      q_service  = @service_ids.present? ? { service_ids: @service_ids } : {}
      q_location = @location_ids.present? ? { location_ids: @location_ids } : {}

      @categories = Facility::Node::Category.in(_id: @category_ids)
      @services   = Facility::Node::Service.in(_id: @service_ids)
      @locations  = Facility::Node::Location.in(_id: @location_ids)

      @items = Facility::Node::Page.site(@cur_site).public.
        where(@cur_node.condition_hash).
        in(q_category).
        in(q_service).
        in(q_location).
        order_by(name: 1)
    end

    def set_markers
      @markers = []
      images = SS::File.where(model: /facility\//).map {|image| [image.id, image.url]}.to_h

      @items.each do |item|
        categories   = item.categories.entries
        category_ids = categories.map(&:id)
        image_id     = categories.map(&:image_id).first

        image_url = images[image_id]
        marker_info  = view_context.render_marker_info(item)

        maps = Facility::Map.site(@cur_site).public.
          where(filename: /^#{item.filename}\//, depth: item.depth + 1).order_by(order: 1)

        maps.each do |map|
          map.map_points.each do |point|
            point[:html] = marker_info
            point[:category] = category_ids
            point[:image] = image_url if image_url.present?
            @markers.push point
          end
        end
      end
    end

  public
    def index
    end

    def map
      #set_items

      @category_ids = params[:category_ids].select(&:present?).map(&:to_i) rescue nil
      @service_ids  = params[:service_ids].select(&:present?).map(&:to_i) rescue nil
      @location_ids = params[:location_ids].select(&:present?).map(&:to_i) rescue nil

      q_category = @category_ids.present? ? { category_ids: @category_ids } : {}
      q_service  = @service_ids.present? ? { service_ids: @service_ids } : {}
      q_location = @location_ids.present? ? { location_ids: @location_ids } : {}

      @categories = Facility::Node::Category.in(_id: @category_ids)
      @services   = Facility::Node::Service.in(_id: @service_ids)
      @locations  = Facility::Node::Location.in(_id: @location_ids)

      @items = []

      images = SS::File.where(model: /facility\//).map {|image| [image.id, image.url]}.to_h
      @markers = []
      Facility::Map.site(@cur_site).public.each do |map|

        parent_path = ::File.dirname(map.filename)
        item = Facility::Node::Page.site(@cur_site).
          where(@cur_node.condition_hash).
          in_path(parent_path).
          in(q_category).
          in(q_service).
          in(q_location).first

        next unless item

        @items << item

        categories   = item.categories.entries
        category_ids = categories.map(&:id)
        image_id     = categories.map(&:image_id).first

        image_url = images[image_id]
        marker_info  = view_context.render_marker_info(item)

        map.map_points.each do |point|
          point[:html] = marker_info
          point[:category] = category_ids
          point[:image] = image_url if image_url.present?
          @markers.push point
        end
      end
    end

    def map_all
      @items = Facility::Node::Page.site(@cur_site).public.
        where(@cur_node.condition_hash).
        order_by(name: 1)

      @categories = Facility::Node::Category.in(_id: [])
      @services   = Facility::Node::Service.in(_id: [])
      @locations  = Facility::Node::Location.in(_id: [])
      set_markers

      render :map
    end

    def result
      set_items
      @items = @items.page(params[:page]).
        per(@cur_node.limit)
    end
end
