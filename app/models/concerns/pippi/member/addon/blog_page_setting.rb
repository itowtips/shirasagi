module Pippi::Member::Addon
  module BlogPageSetting
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      define_list("blog").call
    end
  end
end
