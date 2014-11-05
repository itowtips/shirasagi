class Opendata::Agents::Parts::DatasetGroupController < ApplicationController
  include Cms::PartFilter::View
  helper Opendata::UrlHelper

  public
    def index
      @items = Opendata::DatasetGroup.site(@cur_site).public.
        order_by(name: 1).
        limit(10)

      render
    end
end
