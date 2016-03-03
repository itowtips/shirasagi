class Member::Agents::Nodes::MyGroupController < ApplicationController
  include Cms::NodeFilter::View
  include Member::LoginFilter
  include Cms::PublicFilter::Crud
  helper Member::MypageHelper

  model Member::Group

  prepend_view_path "app/views/member/agents/nodes/my_group"

  before_action :check_rights, only: [:edit, :update, :delete, :destroy, :destroy_all]

  private
    def fix_params
      { cur_site: @cur_site, cur_node: @cur_node, cur_member: @cur_member }
    end

    def get_params
      if params[:action] == 'create'
        { in_admin: @cur_member }.merge(super)
      else
        super
      end
    end

    def check_rights
      raise "403" unless @item.admin_member?(@cur_member)
    end

  public
    def index
      @items = @model.site(@cur_site).and_member(@cur_member).
        order_by(released: -1).
        page(params[:page]).per(20)
    end

    def invite
      set_item
      return if request.get?

      @item.attributes = get_params
      @item.in_updated = params[:_updated] if @item.respond_to?(:in_updated)
      render_update(
        @item.save,
        location: @cur_node.url,
        render: { file: :invite },
        notice: t("member.notice.invited"))
    end

    def accept
      set_item
      return if request.get?

      render_update(
        @item.accept(@cur_member),
        location: @cur_node.url,
        render: { file: :accept },
        notice: t("member.notice.accepted"))
    end

    def reject
      set_item
      return if request.get?

      render_update(
        @item.reject(@cur_member),
        location: @cur_node.url,
        render: { file: :reject },
        notice: t("member.notice.rejected"))
    end
end
