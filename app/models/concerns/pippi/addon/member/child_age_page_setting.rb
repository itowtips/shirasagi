module Pippi::Addon::Member
  module ChildAgePageSetting
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      define_list("child_age").call
    end
  end
end
