module Cms::Addon
  module MenuList
    extend ActiveSupport::Concern
    extend SS::Addon
    include Cms::Addon::List::Model
  end
end
