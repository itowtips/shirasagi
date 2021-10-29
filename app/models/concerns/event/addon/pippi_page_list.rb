module Event::Addon
  module PippiPageList
    extend ActiveSupport::Concern
    extend SS::Addon
    include Cms::Addon::List::Model

    included do
      field :event_display, type: String
      permit_params :event_display
      validates :event_display, inclusion: { in: ['list', 'table', 'list_only', 'table_only'], allow_blank: true }
    end

    def sort_options
      %w(
        name filename created updated_desc released_desc order order_desc
        event_dates unfinished_event_dates finished_event_dates event_dates_today event_dates_tomorrow event_dates_week
        event_deadline event_dates_weekend
      ).map do |k|
        description = I18n.t("event.sort_options.#{k}.description", default: [ "cms.sort_options.#{k}.description".to_sym, nil ])

        [
          I18n.t("event.sort_options.#{k}.title".to_sym, default: "cms.sort_options.#{k}.title".to_sym),
          k.sub("_desc", " -1"),
          "data-description" => description
        ]
      end
    end

    def condition_hash(options = {})
      h = super
      today = Time.zone.today
      case sort
      when "event_dates"
        { "$and" => [ h, { "event_dates.0" => { "$exists" => true } } ] }
      when "unfinished_event_dates"
        { "$and" => [ h, { "event_dates" => { "$elemMatch" => { "$gte" => today } } } ] }
      when "finished_event_dates"
        { "$and" => [ h, { "event_dates" => { "$elemMatch" => { "$lt" => today } } } ] }
      when "event_dates_today"
        { "$and" => [ h, { "event_dates" => { "$eq" => today } } ] }
      when "event_dates_tomorrow"
        { "$and" => [ h, { "event_dates" => { "$eq" => 1.day.since(today) } } ] }
      when "event_dates_week"
        { "$and" => [ h, { "event_dates" => { "$elemMatch" => { "$gte" => today, "$lte" => 1.week.since(today) } } } ] }
      when "event_deadline"
        { "$and" => [ h, { "event_deadline" => { "$gte" => today } } ] }
      when "event_dates_weekend"
        {
          "$and" => [
            h,
            {
              "event_dates" => {
                "$elemMatch" => {
                  "$gte" => (today..1.week.since(today)).find{ |date| date.saturday? },
                  "$lte" => (today..1.week.since(today)).find{ |date| date.sunday? }
                }
              }
            }
          ]
        }
      else h
      end
    end

    def sort_hash
      return { released: -1 } if sort.blank?

      if sort.include?("event_dates")
        event_dates_sort_hash
      else
        { sort.sub(/ .*/, "") => (/-1$/.match?(sort) ? -1 : 1) }
      end
    end

    def event_dates_sort_hash
      if sort == "finished_event_dates"
        { "event_dates.0" => -1 }
      else
        { "event_dates.0" => 1 }
      end
    end

    def event_display_options
      %w(list table list_only table_only).collect do |m|
        [ I18n.t("event.options.event_display.#{m}"), m ]
      end
    end

    def sort_event_page_by_difference(criteria)
      today = Time.zone.today
      case sort
      when "event_dates_today"
        dates = [today]
      when "event_dates_weekend"
        dates = (today..1.week.since(today)).select do |date|
          date.saturday? || date.sunday?
        end
      else
        return criteria.to_a
      end

      event_sort_hash = {}
      criteria.each do |item|
        event_sort_hash[item.id.to_s] = {}
        next unless item.event_dates_cluster(dates)

        event_sort_hash[item.id.to_s]['difference'] = item.event_dates_difference(dates)
        event_sort_hash[item.id.to_s]['end_date'] = item.event_dates_cluster(dates).last
      end
      i = 0
      criteria.sort_by do |item|
        [event_sort_hash[item.id.to_s]['difference'], event_sort_hash[item.id.to_s]['end_date'], i += 1]
      end
    end
  end
end
