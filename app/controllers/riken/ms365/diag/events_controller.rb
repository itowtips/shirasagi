class Riken::MS365::Diag::EventsController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter

  navi_view 'riken/ms365/main/conf_navi'
  # menu_view "riken/ms365/diag/events/menu"

  before_action :check_permissions, :set_search_params

  helper_method :room_options

  private

  def check_permissions
    raise "403" unless Gws::Group.allowed?(:edit, @cur_user, site: @cur_site)
  end

  def set_crumbs
    @crumbs << [t("riken.ms365.main"), gws_riken_ms365_main_path]
    @crumbs << [t("riken.ms365.event"), url_for(action: :index)]
  end

  def room_options
    @room_options ||= begin
      options = []
      Riken::MS365::GraphApi.each_room(@cur_site) do |entry|
        options << [ entry["displayName"], entry["emailAddress"] ]
      end
      options.sort_by! { |option| option[0] }
      options
    end
  end

  def set_search_params
    @s ||= begin
      today = Time.zone.today
      s = OpenStruct.new(params[:s])
      s.room_id ||= room_options.first.try { |option| option[1] }
      s.from ||= today - today.wday.days
      s.to ||= s.from.in_time_zone + 6.days
      s
    end
  end

  public

  def index
    render
  end

  def new
    render
  end

  def create
    safe_params = params.require(:item).permit(:room_id, :subject, :start, :end, :body, :attendees)

    @resp = Riken::MS365::GraphApi.create_event(@cur_site, safe_params[:room_id], safe_params.except(:room_id))
  end
end
