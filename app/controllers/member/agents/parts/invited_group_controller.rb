class Member::Agents::Parts::InvitedGroupController < ApplicationController
  include Cms::PartFilter::View
  include Member::LoginFilter
  helper Cms::ListHelper

  skip_filter :logged_in?
  before_action :becomes_with_route
  before_action :set_member

  private
    def becomes_with_route
      @cur_part = @cur_part.becomes_with_route
    end

    def set_member
      logged_in? redirect: false
    end

  public
    def index
      return if @cur_member.blank?
      @items = Member::Group.site(@cur_site).and_invited(@cur_member)
    end
end
