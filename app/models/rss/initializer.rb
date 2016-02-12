module Rss
  class Initializer
    Cms::Node.plugin "rss/page"
    Cms::Node.plugin "rss/pub_sub_hubbub"
  end
end
