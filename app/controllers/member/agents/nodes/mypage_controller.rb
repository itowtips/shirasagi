class Member::Agents::Nodes::MypageController < ApplicationController
  include Cms::NodeFilter::View
  include Member::LoginFilter

  public
    def index
    end
end
