class Gws::Discussion::PlansController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter
  include Gws::Schedule::PlanFilter

  before_action :set_topic
  before_action :set_items

  private

  def set_topic
    @topic =  Gws::Discussion::Topic.find(params[:topic_id])
  end

  def set_crumbs
    set_topic
    @crumbs << [t('modules.gws/discussion'), gws_discussion_main_path]
    @crumbs << [@topic.name, gws_discussion_topic_comments_path(topic_id: @topic.id)]
    @crumbs << ["スケジュール", gws_discussion_topic_plans_path(topic_id: @topic.id)]
  end

  def set_items
    @items = []
  end

  public

  def index
    return render if params[:format] != 'json'

    @items = Gws::Schedule::Plan.site(@cur_site).
      member(@cur_user).
      #allow(:read, @cur_user, site: @cur_site).
      search(params[:s])
  end

  def events
    @start_at = params[:s][:start].to_date
    @end_at = params[:s][:end].to_date

    @todos = Gws::Schedule::Todo.
      site(@cur_site).
      allow(:read, @cur_user, site: @cur_site).
      active().
      search(start: @start_at, end: @end_at).
      map do |todo|
        result = todo.calendar_format(@cur_user, @cur_site)
        result[:restUrl] = gws_schedule_todos_path(site: @cur_site.id)
        result
    end

    @holidays = HolidayJapan.between(@start_at, @end_at).map do |date, name|
      { className: 'fc-holiday', title: "  #{name}", start: date, allDay: true, editable: false, noPopup: true }
    end

    @items = @todos + @holidays
  end
end
