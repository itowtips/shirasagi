module Gws::Workflow::WizardFilter
  extend ActiveSupport::Concern
  include Gws::ApiFilter
  include Workflow::WizardFilter

  included do
    prepend_view_path "app/views/workflow/wizard"

    before_action :set_route, only: [:approver_setting]
    before_action :set_item
  end

  private

  def set_model
    @model = Gws::Workflow::File
  end

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site }
  end

  def set_route
    @route_id = params[:route_id]
    if %w(my_group restart).include?(@route_id)
      @route = nil
    else
      @route = Gws::Workflow::Route.find(params[:route_id])
    end
  end

  def set_item
    @item = @model.find(params[:id])
    @item.attributes = fix_params
  end

  public

  def index
    render file: :index, layout: false
  end

  def approver_setting
    @item.workflow_user_id = nil
    @item.workflow_state = nil
    @item.workflow_comment = nil
    if @route_id != "restart"
      @item.workflow_approvers = nil
      @item.workflow_required_counts = nil
    end

    if @route.present?
      if @item.apply_workflow?(@route)
        render file: "approver_setting_multi", layout: false
      else
        render json: @item.errors.full_messages, status: :bad_request
      end
    elsif @route_id == "my_group"
      render file: :approver_setting, layout: false
    elsif @route_id == "restart"
      render file: "approver_setting_restart", layout: false
    else
      raise "404"
    end
  end

  def reroute
    if params.dig(:s, :group).present?
      @group = @cur_site.descendants.active.find(params.dig(:s, :group)) rescue nil
      @group ||= @cur_site
    else
      @group = @cur_user.groups.active.in_group(@cur_site).first
    end

    @cur_user = @item.class.approver_user_class.site(@cur_site).active.find(params[:user_id]) rescue nil

    level = Integer(params[:level])

    workflow_approvers = @item.workflow_approvers
    workflow_approvers = workflow_approvers.select do |workflow_approver|
      workflow_approver[:level] == level
    end
    same_level_user_ids = workflow_approvers.map do |workflow_approver|
      workflow_approver[:user_id]
    end

    group_ids = @cur_site.descendants.active.in_group(@group).pluck(:id)
    criteria = @item.class.approver_user_class.site(@cur_site)
    criteria = criteria.active
    criteria = criteria.in(group_ids: group_ids)
    criteria = criteria.nin(id: same_level_user_ids + [ @item.workflow_user_id, @item.workflow_agent_id ].compact)
    criteria = criteria.search(params[:s])
    criteria = criteria.order_by_title(@cur_site)

    @items = criteria.select do |user|
      @item.allowed?(:read, user, site: @cur_site) && @item.allowed?(:approve, user, site: @cur_site)
    end
    @items = Kaminari.paginate_array(@items).page(params[:page]).per(50)

    render file: 'reroute', layout: false
  end

  def approve_by_delegatee
    @level = Integer(params[:level])
    @delegator = @item.class.approver_user_class.site(@cur_site).active.find(params[:delegator_id]) rescue nil

    render file: 'approve_by_delegatee', layout: false
  end
end
