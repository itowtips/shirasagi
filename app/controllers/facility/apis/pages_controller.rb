class Facility::Apis::PagesController < ApplicationController
  include Cms::ApiFilter

  model Facility::Node::Page

  def index
    @single = params[:single].present?
    @multi = !@single
    set_items
  end

  def set_items
    @search_node = Facility::Node::Search.find(params[:search_node_id]) rescue nil

    dump params

    if @search_node
      @items = @model.site(@cur_site).and_public.
        where(@search_node.condition_hash).
        search(params[:s]).
        order_by(name: 1).
        page(params[:page]).per(50)
    else
      @items = @model.site(@cur_site).and_public.
        search(params[:s]).
        order_by(name: 1).
        page(params[:page]).per(50)
    end
  end
end
