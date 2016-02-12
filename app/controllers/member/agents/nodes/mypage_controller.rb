class Member::Agents::Nodes::MypageController < ApplicationController
  include Cms::NodeFilter::View
  include Member::LoginFilter

  public
    def index
      child = @cur_node.children.first

      raise "404" unless child
      redirect_to child.url
    end
end
