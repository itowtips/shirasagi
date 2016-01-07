class Member::Agents::Nodes::MyBlog::SettingController < ApplicationController
  include Cms::NodeFilter::View
  include Member::LoginFilter
  include Cms::PublicFilter::Crud

  before_action :set_item
  before_action :redirect_to_edit, only: [:new, :create]

  prepend_view_path "app/views/member/agents/nodes/my_blog/setting"

  model Member::Blog

  private
    def set_item
      @item = @cur_node.blog(@cur_member)
      @cur_node.name += "設定"
    end

    def redirect_to_edit
      redirect_to "#{@cur_node.setting_url}edit" if @item
    end

    def fix_params
      { cur_site: @cur_site, cur_member: @cur_member }
    end
end
