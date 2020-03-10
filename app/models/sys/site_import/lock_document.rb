class Sys::SiteImport::LockDocument
  include Mongoid::Document

  field :ref_id, type: Integer
  field :ref_collection_name, type: String

  validates :ref_id, presence: true
  validates :ref_collection_name, presence: true

  class << self
    def create_lock_documents(klass)
      ids = klass.pluck(:id)
      ids.each do |id|
        item = klass.find(id) rescue nil
        next unless item

        lock = Sys::SiteImport::LockDocument.new
        lock.ref_id = item.id
        lock.ref_collection_name = item.class.collection.name
        lock.save!
      end
    end
  end
end
