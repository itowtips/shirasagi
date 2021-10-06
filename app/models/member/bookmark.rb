class Member::Bookmark
  include SS::Document
  include SS::Reference::Site
  include Cms::Reference::Member

  field :name, type: String
  belongs_to :content, class_name: "Object", polymorphic: true

  validates :name, presence: true

  before_validation :set_name

  default_scope ->{ order_by(updated: -1) }

  private

  def set_name
    self.name = content.try(:name)
  end

  class << self
    def and_public
      where(:deleted.exists => false)
    end
  end
end
