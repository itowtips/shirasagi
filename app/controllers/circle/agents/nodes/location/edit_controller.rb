module Circle::Agents::Nodes::Location
  class EditController < ApplicationController
    include Cms::NodeFilter::Edit
    model Circle::Node::Location
  end
end
