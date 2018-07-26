class Opendata::Harvest
  include SS::Document
  include SS::Reference::User
  include SS::Reference::Site
  include Cms::Reference::Node
  include Opendata::Addon::Harvest::Importer
  include Opendata::Addon::Harvest::CategorySetting
  include Opendata::Addon::Harvest::EstatCategorySetting
  include Opendata::Addon::Harvest::AreaSetting
  include Opendata::Addon::Harvest::Report
  include Cms::Addon::GroupPermission
  include ActiveSupport::NumberHelper

  set_permission_name "opendata_harvests", :edit

  seqid :id

  field :name, type: String
  field :source_url, type: String
  field :api_type, type: String
  field :order, type: Integer, default: 0
  field :resource_size_limit_mb, type: Integer, default: 0

  field :source_host, type: String

  validates :name, presence: true
  validates :api_type, presence: true
  validates :source_url, presence: true
  validate :validate_host, if: -> { source_url.present? }

  has_many :datasets, class_name: 'Opendata::Dataset', inverse_of: :harvest
  has_many :reports, class_name: 'Opendata::Harvest::Report', dependent: :destroy, inverse_of: :harvest

  permit_params :name, :source_url, :api_type, :order, :resource_size_limit_mb

  default_scope -> { order_by(order: 1) }

  private

  def validate_host
    begin
      self.source_host = ::URI.parse(source_url).host
    rescue => e
      errors.add :source_host, :invalid
    end
  end

  public

  def order
    value = self[:order].to_i
    value < 0 ? 0 : value
  end

  def api_type_options
    [
      ["Ckan API", "ckan"],
      ["Shirasagi API", "shirasagi_api"],
      ["Shirasagi スクレイピング", "shirasagi_scraper"],
    ]
  end
end
