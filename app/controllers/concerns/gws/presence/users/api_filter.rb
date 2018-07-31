module Gws::Presence::Users::ApiFilter
  extend ActiveSupport::Concern

  included do
    model Gws::User

    prepend_view_path "app/views/gws/presence/apis/users"

    skip_before_action :set_item

    before_action :set_groups
    before_action :set_editable_users
    before_action :set_manageable
  end

  private

  def get_params
    params.permit(:presence_state, :presence_plan, :presence_memo)
  end

  def user_presence_json
    {
      id: @item.user_id,
      name: @item.user.name,
      presence_state: @item.state,
      presence_state_label: @item.label(:state),
      presence_plan: @item.plan,
      presence_memo: @item.memo,
      editable: @editable_user_ids.include?(@item.user_id),
      manageable: @manageable
    }
  end

  def set_groups
    @groups = [@cur_site.root.to_a, @cur_site.root.descendants.to_a].flatten
  end

  def set_editable_users
    @editable_users = @cur_user.presence_editable_users(@cur_site)
    @editable_user_ids = @editable_users.map(&:id)
  end

  def set_manageable
    @manageable = Gws::UserPresence.other_permission?(:edit, @cur_user, site: @cur_site)
  end

  def set_user
    @user = @model.where(id: params[:id]).in(group_ids: @groups.pluck(:id)).first
  end

  public

  def index
    raise "403" unless Gws::UserPresence.allowed?(:edit, @cur_user, site: @cur_site)

    @items = @model.in(group_ids: @groups.pluck(:id))
    if params[:limit]
      @items = @items.page(params[:page].to_i).per(params[:limit])
    end
  end

  def show
    raise "403" unless Gws::UserPresence.allowed?(:edit, @cur_user, site: @cur_site)

    set_user
    raise "404" unless @user

    @items = [@user]
  end

  def update
    set_user
    raise "404" unless @user

    if @editable_user_ids.include?(@user.id)
      raise "403" unless Gws::UserPresence.allowed?(:edit, @cur_user, site: @cur_site)
    else
      raise "403" unless Gws::UserPresence.other_permission?(:edit, @cur_user, site: @cur_site)
    end

    @item = @user.user_presence(@cur_site) || Gws::UserPresence.new
    @item.cur_site = @cur_site
    @item.cur_user = @user

    @item.attributes = get_params
    if @item.update
      respond_to do |format|
        format.json { render json: user_presence_json, status: :ok, content_type: json_content_type }
      end
    else
      respond_to do |format|
        format.json { render json: @item.errors.full_messages, status: :unprocessable_entity, content_type: json_content_type }
      end
    end
  end
end