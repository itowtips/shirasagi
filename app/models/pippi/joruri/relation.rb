module Pippi::Joruri::Relation
  class Doc
    include Mongoid::Document

    belongs_to :owner_item, class_name: "Object", polymorphic: true
    field :joruri_id, type: Integer
    field :joruri_url, type: String
    field :joruri_updated, type: DateTime

    validates :owner_item_id, presence: true
    validates :joruri_id, presence: true
  end

  class Hint < Doc
  end

  class Bousai < Doc
  end
end
