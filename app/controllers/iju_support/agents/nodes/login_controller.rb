class IjuSupport::Agents::Nodes::LoginController < ApplicationController
  include Cms::NodeFilter::View
  include JobDb::LoginFilter

  self.member_class = IjuSupport::Member
  self.member_login_node_class = IjuSupport::Node::Login
end
