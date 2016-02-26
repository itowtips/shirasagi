module Rss
  class Initializer
    Cms::Node.plugin "rss/page"
    Cms::Node.plugin "rss/pub_sub_hubbub"
    Cms::Node.plugin "rss/weather_xml"
  end
end
