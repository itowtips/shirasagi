class Member::Agents::Parts::PhotoSearchController < ApplicationController
  include Cms::PartFilter::View

  public
    def index
      @node = @cur_part.parent
      return render nothing: true unless @node

      @locations  = Member::Node::PhotoLocation.site(@cur_site).public
      @categories = Member::Node::PhotoCategory.site(@cur_site).public
      @query      = {
        keyword: "",
        contributor: "",
        location_ids: [],
        category_ids: [],
        locations: [],
        categories: [],
      }
    end
end
