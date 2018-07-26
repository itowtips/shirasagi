class Opendata::Resource
  include SS::Document
  include Opendata::Resource::Model
  include Opendata::Addon::RdfStore
  include Opendata::Addon::CmsRef::AttachmentFile
  include Opendata::Addon::Harvest::Resource

  attr_accessor :workflow, :status

  embedded_in :dataset, class_name: "Opendata::Dataset", inverse_of: :resource
  field :order, type: Integer, default: 0

  permit_params :name, :text, :format, :license_id, :source_url

  validates :in_file, presence: true, if: ->{ file_id.blank? && source_url.blank? }
  validates :format, presence: true
  validates :source_url, format: /\A#{URI::regexp(%w(https http))}$\z/, if: ->{ source_url.present? }

  before_validation :set_filename, if: ->{ in_file.present? }
  before_validation :validate_in_file, if: ->{ in_file.present? }
  before_validation :validate_in_tsv, if: ->{ in_tsv.present? }
  before_validation :set_format

  after_save :save_dataset

  def context_path
    "/resource"
  end

  def create_download_history
    Opendata::ResourceDownloadHistory.create_download_history(
      dataset_id: dataset.id,
      resource_id: id
    )
  end

  private

  def set_filename
    self.filename = in_file.original_filename
    self.format = filename.sub(/.*\./, "").upcase if format.blank?
  end

  def validate_in_file
    if %(CSV TSV).index(format)
      errors.add :file_id, :invalid if parse_tsv(in_file).blank?
    end
  end

  def validate_in_tsv
    errors.add :tsv_id, :invalid if parse_tsv(in_tsv).blank?
  end

  def set_format
    self.format = format.upcase if format.present?
    self.rm_tsv = "1" if %(CSV TSV).index(format)
  end

  def save_dataset
    self.workflow ||= {}
    dataset.cur_site = dataset.site
    dataset.apply_status(status, workflow) if status.present?
    dataset.released ||= Time.zone.now
    dataset.save(validate: false)
  end
end
