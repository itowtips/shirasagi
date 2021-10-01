class Pippi::Agents::Parts::TipsController < ApplicationController
  include Cms::PartFilter::View

  def index
    if @cur_part.parent.try(:route) == "pippi/tips"
      @node = @cur_part.parent
    else
      @node = Pippi::Node::Tips.site(@cur_site).firsts
    end
    raise "404" unless @node

    @item = Pippi::Tips.site(@cur_site).node(@node).where(date: Time.zone.today).first
  end
end
