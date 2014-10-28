class Circle::MainController < ApplicationController
  include Cms::BaseFilter

  public
    def index
      if @cur_node.route =~ /\/category/
        redirect_to circle_categories_path
        return
      elsif @cur_node.route =~ /\/location/
        redirect_to circle_locations_path
        return
      elsif @cur_node.route =~ /\/use/
        redirect_to circle_uses_path
        return
      else
        redirect_to circle_pages_path
        return
      end
    end
end
