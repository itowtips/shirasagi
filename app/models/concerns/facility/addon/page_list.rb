module Facility::Addon
  module PageList
    extend ActiveSupport::Concern
    extend SS::Addon
    include Cms::Addon::List::Model

    def sort_options
      [
        [I18n.t('event.options.sort.name'), 'name'],
        [I18n.t('event.options.sort.filename'), 'filename'],
        [I18n.t('event.options.sort.created'), 'created'],
        [I18n.t('event.options.sort.updated_1'), 'updated -1'],
        [I18n.t('event.options.sort.released_1'), 'released -1'],
        [I18n.t('event.options.sort.order'), 'order'],
        [I18n.t('event.options.sort.event_dates'), 'event_dates'],
        [I18n.t('event.options.sort.unfinished_event_dates'), 'unfinished_event_dates'],
      ]
    end

    def sort
      value = self[:sort]
      if value
        value
      else
        "unfinished_event_dates"
      end
    end

    def loop_html
      value = self[:loop_html]
      if value
        value
      else
        h = []
        h << '<article class="item-#{class} #{new} #{current}">'
        h << '  <header>'
        h << '    #{event_dates.long}'
        h << '    <h3><a href="#{url}">#{index_name}</a></h3>'
        h << '  </header>'
        h << '</article>'
        h.join("\n")
      end
    end

    def condition_hash(opts = {})
      h = super
      if sort == "event_dates"
        { "$and" => [ h, { "event_dates.0" => { "$exists" => true } } ] }
      elsif sort == "unfinished_event_dates"
        { "$and" => [ h, { "event_dates" => { "$elemMatch" => { "$gte" => Time.zone.today } } } ] }
      else
        h
      end
    end

    def sort_hash
      return { released: -1 } if sort.blank?

      if sort =~ /event_dates/
        { "event_dates.0" => 1 }
      else
        { sort.sub(/ .*/, "") => (sort =~ /-1$/ ? -1 : 1) }
      end
    end
  end
end
