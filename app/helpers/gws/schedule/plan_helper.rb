module Gws::Schedule::PlanHelper
  extend ActiveSupport::Concern

  def search_query
    params.to_unsafe_h.select { |k, v| k == 's' }.to_query
  end

  def term(item)
    if item.allday?
      # 2022/1/20 の終日イベントを、いかなるタイムゾーンであっても 2022/1/20 の終日イベントするため
      # タイムゾーンがついていない start_on /end_on を用いて書式化する必要がある。
      from = item.start_on
      to = item.end_on
    else
      from = item.start_at
      to = item.end_at
    end
    return I18n.l(from, format: :gws_long) if from == to

    format = find_term_format(from, to)
    I18n.l(from, format: :gws_long) + ' - ' + I18n.l(to, format: format)
  end

  def calendar_format(plans, opts = {})
    events = plans.map do |m|
      event = m.calendar_format(@cur_user, @cur_site)
      event = m.set_attendance_classes(event, @cur_user, opts[:user].to_i)
    end
    events.compact!
    return events unless opts[:holiday]

    events += calendar_holidays opts[:holiday][0], opts[:holiday][1]
    events += group_holidays opts[:holiday][0], opts[:holiday][1]
    events += calendar_todos(opts[:holiday][0], opts[:holiday][1])
    events
  end

  def group_holidays(start_at, end_at)
    Gws::Schedule::Holiday.site(@cur_site).and_public.
      search(start: start_at, end: end_at).
      map(&:calendar_format)
  end

  def calendar_holidays(start_at, end_at)
    HolidayJapan.between(start_at, end_at).map do |date, name|
      { className: 'fc-holiday', title: "  #{name}", start: date, allDay: true, editable: false, noPopup: true }
    end
  end

  def calendar_todos(start_at, end_at)
    return [] if @todos.blank?

    @todos.map do |todo|
      result = todo.calendar_format(@cur_user, @cur_site)
      result[:restUrl] = gws_schedule_todo_readables_path(category: Gws::Schedule::TodoCategory::ALL.id)
      result
    end
  end

  private

  def find_term_format(from, to)
    format = "gws_long"
    return format.to_sym if from.year != to.year

    format = "#{format}_without_year"
    return format.to_sym if from.month != to.month

    format = "#{format}_month"
    return format.to_sym if !from.respond_to?(:sec) || from.day != to.day

    format = "#{format}_day"
    format.to_sym
  end
end
