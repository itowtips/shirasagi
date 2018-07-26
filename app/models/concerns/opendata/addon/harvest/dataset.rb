module Opendata::Addon::Harvest::Dataset
  extend SS::Addon
  extend ActiveSupport::Concern

  included do
    field :uuid, type: String, default: nil

    belongs_to :harvest, class_name: 'Opendata::Harvest'
    #belongs_to :harvest_report, class_name: 'Opendata::Harvest::Report'

    field :harvest_imported, type: DateTime, default: nil
    field :harvest_imported_url, type: String, default: nil
    field :harvest_imported_attributes, type: Hash, default: {}

    field :harvest_host, type: String, default: nil
    field :harvest_api_type, type: String, default: nil
    field :harvest_text_index, type: String, default: ""

    before_validation :set_uuid
    before_validation :set_harvest_text_index, if: -> { harvest_imported.present? }

    validates :uuid, presence: true
  end

  def harvest_ckan_groups
    ckan_groups = harvest_imported_attributes.dig("groups").to_a
    ckan_groups.map { |g| g["display_name"] }
  end

  def harvest_ckan_tags
    ckan_tags = harvest_imported_attributes.dig("tags").to_a
    ckan_tags.map { |g| g["display_name"] }
  end

  def harvest_shirasagi_categories
    shirasagi_categories = harvest_imported_attributes.dig("categories").to_a
    shirasagi_categories
  end

  def harvest_shirasagi_areas
    shirasagi_areas = harvest_imported_attributes.dig("areas").to_a
    shirasagi_areas
  end

  def set_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def set_harvest_text_index
    texts = []
    %w(name text).map do |name|
      text = send(name)
      next if text.blank?
      text.gsub!(/\s+/, " ")
      texts << text
    end

    if harvest_api_type =~ /^ckan/
      texts += harvest_ckan_groups
      texts += harvest_ckan_tags
    end

    # resources
    texts += resources.pluck(:harvest_text_index)

    self.harvest_text_index = texts.uniq.join(" ")
  end
end
