module Pippi::Member::Addon
  module EventBookmarkSetting
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      define_list("event").call
    end
  end
end
