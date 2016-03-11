class Rss::Agents::Nodes::PubSubHubbubController < ApplicationController
  include Cms::NodeFilter::View
  include Rss::Public::PubSubHubbubFilter
  helper Cms::ListHelper

  private
    def protect_csrf?
      false
    end
end
