module Gws::Addon::Discussion::Todo
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    belongs_to :discussion_topic, class_name: "Gws::Discussion::Topic"
  end
end
