module Circle::Agents::Nodes::Page
  class EditController < ApplicationController
    include Cms::NodeFilter::Edit
    model Circle::Node::Page
  end
end
