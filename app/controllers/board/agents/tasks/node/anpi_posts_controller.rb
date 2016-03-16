class Board::Agents::Tasks::Node::AnpiPostsController < ApplicationController
  include Cms::PublicFilter::Node

  def generate
    generate_node @node
  end
end
