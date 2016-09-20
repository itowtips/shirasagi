class Facility::Agents::Tasks::Node::PagesController < ApplicationController
  include Cms::PublicFilter::Node

  def generate
    return nil unless @facilities

    # save for chache
    @node.becomes_with_route.save
    generate_node @node
  end
end
