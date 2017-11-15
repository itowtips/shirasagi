module Gws::Addon::Discussion::Todo
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    belongs_to :discussion_topic, class_name: "Gws::Discussion::Topic"

    scope :discussion_topic, ->(discussion_topic) { where(discussion_topic_id: discussion_topic.id) }
  end
end
