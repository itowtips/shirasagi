class Cms::Agents::Parts::MenuController < ApplicationController
  include Cms::PartFilter::View
  helper Cms::MenuHelper

  def index
    @items = @cur_part.menu_links.map { |link| link[:item] }
  end
end
