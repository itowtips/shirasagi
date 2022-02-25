class Category::Agents::Nodes::PageController < ApplicationController
  include Cms::NodeFilter::View
  helper Cms::ListHelper
  include Cms::NodeFilter::ListView

  private

  def pages
    pages = Cms::Page.public_list(site: @cur_site, node: @cur_node, date: @cur_date)
    if params[:column_values_value].present?
      cond = {
        column_values: {
          "$elemMatch" => {
            value: params[:column_values_value]
          }
        }
      }
      pages = pages.where(cond)
    end
    pages
  end
end
