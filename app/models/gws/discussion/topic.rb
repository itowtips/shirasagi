class Gws::Discussion::Topic
  include Gws::Referenceable
  include Gws::Discussion::Postable
  include SS::Addon::Markdown
  include Gws::Addon::File
  include Gws::Addon::Release
  include Gws::Addon::ReadableSetting
  include Gws::Addon::GroupPermission
  include Gws::Addon::History

  readable_setting_include_custom_groups

  has_one :main_post, class_name: "Gws::Discussion::Post", inverse_of: :main_topic

  after_validation :set_descendants_updated_with_released, if: -> { released.present? && released_changed? }

  validates :text, presence: true

  # indexing to elasticsearch via companion object
  around_save ::Gws::Elasticsearch::Indexer::BoardTopicJob.callback
  around_destroy ::Gws::Elasticsearch::Indexer::BoardTopicJob.callback

  def updated?
    created.to_i != updated.to_i || created.to_i != descendants_updated.to_i
  end

  private

  def set_descendants_updated_with_released
    if descendants_updated.present?
      self.descendants_updated = released if descendants_updated < released
    else
      self.descendants_updated = released
    end
  end
end
