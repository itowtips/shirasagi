module Opendata::Addon::Harvest::Resource
  extend SS::Addon
  extend ActiveSupport::Concern

  included do
    field :uuid, type: String, default: nil
    field :revision_id, type: String, default: nil

    belongs_to :harvest_importer, class_name: 'Opendata::Harvest::Importer'
    #belongs_to :harvest_importer_report, class_name: 'Opendata::Harvest::Importer::Report'

    field :harvest_imported, type: DateTime, default: nil
    field :harvest_imported_url, type: String, default: nil
    field :harvest_imported_attributes, type: Hash, default: {}

    field :harvest_host, type: String, default: nil
    field :harvest_api_type, type: String, default: nil
    field :harvest_text_index, type: String, default: nil

    before_validation :set_uuid
    before_validation :set_harvest_text_index, if: -> { harvest_imported.present? }

    validates :uuid, presence: true

    before_save :set_revision_id
  end

  def set_harvest_text_index
    texts = []
    %w(name text filename).map do |name|
      text = send(name)
      next if text.blank?
      text.gsub!(/\s+/, " ")
      texts << text
    end

    # license
    texts << license.name if license

    self.harvest_text_index = texts.uniq.join(" ")
  end

  def set_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def set_revision_id
    return true if !changed?
    return true if !record_timestamps
    self.revision_id = SecureRandom.uuid
  end
end
