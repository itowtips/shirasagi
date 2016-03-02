class Member::Agents::Nodes::MyAnpiPostController < ApplicationController
  include Cms::NodeFilter::View
  include Member::LoginFilter
  include Cms::PublicFilter::Crud
  helper Member::MypageHelper

  model Board::AnpiPost
  prepend_view_path "app/views/member/agents/nodes/my_anpi_post"
  before_action :deny
  before_action :set_groups
  before_action :set_cur_group, only: [:index]
  before_action :check_owner, only: [:edit, :update, :delete, :destroy, :destroy_all]

  private
    def fix_params
      { cur_site: @cur_site, cur_node: @cur_node, cur_member: @cur_member }
    end

    def pre_params
      if params[:action] == 'new'
        params = { name: @cur_member.name }
        params[:kana] = @cur_member.try(:kana)
        params[:tel] = @cur_member.try(:tel)
        params[:addr] = @cur_member.try(:addr)
        params[:sex] = @cur_member.try(:sex)
        params[:age] = @cur_member.try(:age)
        params
      else
        {}
      end
    end

    def deny
      if @cur_node.deny_ips.present?
        remote_ip = request.env["HTTP_X_REAL_IP"] || request.remote_ip
        @cur_node.deny_ips.each do |deny_ip|
          raise "403" if remote_ip =~ /^#{deny_ip}/
        end
      end
    end

    def set_groups
      @cur_groups ||= Member::Group.site(@cur_site).and_member(@cur_member).order_by(released: -1).to_a
    end

    def set_cur_group
      set_groups
      return @cur_group if @cur_group.present?

      group_id = params[:g].presence
      group_id = Integer(group_id) rescue nil if group_id.present?
      @cur_group ||= @cur_groups.first if group_id.blank? && @cur_groups.count == 1
      @cur_group ||= @cur_groups.find { |item| item.id = group_id }
    end

    def check_owner
      raise "403" unless @item.owned?(@cur_member)
    end

  public
    def index
      if @cur_group.present?
        @items = Board::AnpiPost.site(@cur_site).
          and_member_group(@cur_group).
          and_public_for(@cur_member).
          order_by(released: -1).
          page(params[:page]).per(20)
      end
    end

    # def others_show
    #   render
    # end

    def others_new
      @item = @model.new pre_params.merge(fix_params)
    end

    def others_create
      @item = @model.new get_params
      render_create @item.save, location: @cur_node.url
    end

    # def others_edit
    #   render
    # end

    # def others_update
    #   @item.attributes = get_params
    #   @item.in_updated = params[:_updated] if @item.respond_to?(:in_updated)
    #   render_update @item.update, location: @cur_node.url
    # end

    # def others_delete
    #   render
    # end

    # def others_destroy
    #   render_destroy @item.destroy
    # end
end
