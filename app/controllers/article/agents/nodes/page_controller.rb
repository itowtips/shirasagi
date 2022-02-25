class Article::Agents::Nodes::PageController < ApplicationController
  include Cms::NodeFilter::View
  include Cms::ForMemberFilter::Node
  include Cms::NodeFilter::ListView

  private

  def pages
    pages = Article::Page.public_list(site: @cur_site, node: @cur_node, date: @cur_date)
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
