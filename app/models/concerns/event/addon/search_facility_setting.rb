module Event::Addon
  module SearchFacilitySetting
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :search_url_state, type: String
      permit_params :search_url_state

      field :map_html, type: String, default: ""
    end

    def search_url_state_options
      [
        [I18n.t('event.options.search_url_state.disabled'), 'index'],
        [I18n.t('event.options.search_url_state.front_map'), 'map'],
        [I18n.t('event.options.search_url_state.front_result'), 'list'],
      ]
    end

    def search_url
      if search_url_state == "map"
        "#{url}map.html"
      elsif search_url_state == "list"
        "#{url}list.html"
      else
        "#{url}search.html"
      end
    end
  end
end
