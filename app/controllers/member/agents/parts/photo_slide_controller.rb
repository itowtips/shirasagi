class Member::Agents::Parts::PhotoSlideController < ApplicationController
  include Cms::PartFilter::View

  public
    def index
      @node = @cur_part.parent
      return render nothing: true unless @node

      @items = Member::Photo.site(@cur_site).
        node(@node).
        public(@cur_date).
        slideable.
        order_by(order: 1)
    end
end
