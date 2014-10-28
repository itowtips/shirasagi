module Circle::Agents::Nodes::Node
  class EditController < ApplicationController
    include Cms::NodeFilter::Edit
    model Circle::Node::Node
  end
end
