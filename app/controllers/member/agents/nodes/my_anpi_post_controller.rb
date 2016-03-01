class Member::Agents::Nodes::MyAnpiPostController < ApplicationController
  include Cms::NodeFilter::View
  include Member::LoginFilter
  include Cms::PublicFilter::Crud
  helper Member::MypageHelper

  model Board::AnpiPost
  prepend_view_path "app/views/member/agents/nodes/my_anpi_post"
  before_action :set_groups
  before_action :set_cur_group, only: [:index]

  private
    def fix_params
      { cur_site: @cur_site, cur_node: @cur_node, cur_member: @cur_member }
    end

    def set_groups
      @cur_groups ||= Member::Group.site(@cur_site).and_member(@cur_member).
        order_by(released: -1).to_a
    end

    def set_cur_group
      set_groups
      return @cur_group if @cur_group.present?

      group_id = params[:g].presence
      group_id = Integer(group_id) rescue nil if group_id.present?
      @cur_group ||= @cur_groups.first if group_id.blank? && @cur_groups.count == 1
      @cur_group ||= @cur_groups.find { |item| item.id = group_id }
    end

  public
    def index
      if @cur_group.present?
        @items = Board::AnpiPost.site(@cur_site).
          and_member_group(@cur_group).
          order_by(released: -1).
          page(params[:page]).per(20)
      end
    end
end
