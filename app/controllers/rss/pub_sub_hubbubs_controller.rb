class Rss::PubSubHubbubsController < ApplicationController
  include Cms::BaseFilter
  include Cms::PageFilter
  include Rss::PubSubHubbubFilter
end
