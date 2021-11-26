module Pippi::Hamasuku::Relation
  class Page
    include Mongoid::Document

    belongs_to :owner_item, class_name: "Object", polymorphic: true
    field :hamasuku_id, type: Integer
    field :hamasuku_url, type: String

    field :related_page_ids, type: Array, default: []
    field :kana_tags, type: Array, default: []
    field :access_count, type: Integer

    validates :owner_item_id, presence: true
    validates :hamasuku_id, presence: true
  end
end
