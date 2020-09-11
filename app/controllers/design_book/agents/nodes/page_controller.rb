class DesignBook::Agents::Nodes::PageController < ApplicationController
  include Cms::NodeFilter::View

  before_action :set_params

  model DesignBook::Page

  def index
    @item = @model.new(site_id: 0, name: '0', basename: '0')
    if @design_book_number.present?
      @item.design_book_number = @design_book_number
      if @item.valid?
        item = @model.site(@cur_site).and_public(@cur_date).where(design_book_number: @design_book_number).first
        if item.present?
          redirect_to URI.parse(item.url).path
        else
          @item.errors.add :base, :not_found_design_book_number, number: @design_book_number
        end
      end
    end
  end

  private

  def set_params
    safe_params = params.permit(:search_design_book_number)
    @design_book_number = safe_params[:search_design_book_number].presence
  end
end
