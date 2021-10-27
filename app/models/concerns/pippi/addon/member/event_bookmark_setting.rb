module Pippi::Addon::Member
  module EventBookmarkSetting
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      define_list("event").call
    end
  end
end
