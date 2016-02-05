class Member::BlogPagesController < ApplicationController
  include Cms::BaseFilter
  include Cms::PageFilter

  model Member::BlogPage

  before_action :change_node_class

  private
    def fix_params
      { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node }
    end

    def change_node_class
      @cur_node = @cur_node.becomes_with_route
    end
end
