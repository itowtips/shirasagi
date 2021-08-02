module Cms::Addon
  module Line::Service::PageList
    extend ActiveSupport::Concern
    extend SS::Addon
    include Cms::Addon::List::Model

    def interpret_default_location(default_site, &block)
    end
  end
end
