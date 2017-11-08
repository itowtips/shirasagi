class Gws::Discussion::Post
  include Gws::Referenceable
  include Gws::Discussion::Postable
  include Gws::Addon::Contributor
  include SS::Addon::Markdown
  include Gws::Addon::File
  include Gws::Addon::Release
  include Gws::Addon::ReadableSetting
  include Gws::Addon::GroupPermission
  include Gws::Addon::History

  belongs_to :main_topic, class_name: "Gws::Discussion::Post", inverse_of: :main_post

  # indexing to elasticsearch via companion object
  around_save ::Gws::Elasticsearch::Indexer::BoardPostJob.callback
  around_destroy ::Gws::Elasticsearch::Indexer::BoardPostJob.callback
end
