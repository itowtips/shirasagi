FactoryGirl.define do
  factory :rss_node_page, class: Rss::Node::Page, traits: [:cms_node] do
    transient do
      site nil
    end

    cur_site { site ? site : cms_site }
    route "rss/page"
    rss_url { "http://example.com/#{filename}" }
    rss_max_docs 20
    rss_refresh_method { Rss::Node::Page::RSS_REFRESH_METHOD_AUTO }
  end

  factory :rss_node_pub_sub_hubbub, class: Rss::Node::PubSubHubbub, traits: [:cms_node] do
    transient do
      site nil
    end

    cur_site { site ? site : cms_site }
    route "rss/pub_sub_hubbub"
    rss_max_docs 20
    page_state 'public'
  end

  factory :rss_node_weather_xml, class: Rss::Node::WeatherXml, traits: [:cms_node] do
    transient do
      site nil
    end

    cur_site { site ? site : cms_site }
    route "rss/weather_xml"
    rss_max_docs 20
    page_state 'closed'
  end
end
