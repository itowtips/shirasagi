module Pippi::Addon::Member
  module BlogBookmarkSetting
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      define_list("blog").call
    end
  end
end
