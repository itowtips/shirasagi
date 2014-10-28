module Circle::Agents::Nodes::Search
  class EditController < ApplicationController
    include Cms::NodeFilter::Edit
    model Circle::Node::Search
  end
end
