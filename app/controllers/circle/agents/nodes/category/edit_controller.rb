module Circle::Agents::Nodes::Category
  class EditController < ApplicationController
    include Cms::NodeFilter::Edit
    model Circle::Node::Category
  end
end
