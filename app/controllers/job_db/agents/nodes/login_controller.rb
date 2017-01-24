class JobDb::Agents::Nodes::LoginController < ApplicationController
  include Cms::NodeFilter::View
  include JobDb::LoginFilter
end
