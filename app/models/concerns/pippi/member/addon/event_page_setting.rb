module Pippi::Member::Addon
  module EventPageSetting
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      define_list("event").call
    end
  end
end
