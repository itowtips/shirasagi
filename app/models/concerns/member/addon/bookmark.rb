module Member::Addon
  module Bookmark
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      has_many :bookmarks, class_name: "Member::Bookmark", foreign_key: :member_id, dependent: :destroy
    end
  end
end
