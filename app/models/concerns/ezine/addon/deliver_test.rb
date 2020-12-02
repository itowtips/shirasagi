module Ezine::Addon
  module DeliverTest
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      embeds_ids :test_groups, class_name: "Cms::Group"

      permit_params test_group_ids: []
    end
  end
end
