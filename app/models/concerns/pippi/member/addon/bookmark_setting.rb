module Pippi::Member::Addon
  module BookmarkSetting
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      define_list("bookmark").call
    end
  end
end
