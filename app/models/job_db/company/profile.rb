# 企業情報
class JobDb::Company::Profile
  extend SS::Translation
  include SS::Document
  include SS::Relation::File
  include JobDb::Company::TemplateVariable
  include JobDb::Addon::Company::Data
  include JobDb::Addon::Company::Pr
  include JobDb::Addon::Company::Inquiry
  include JobDb::Addon::Company::SeniorMessage
  include JobDb::Addon::Company::GuideAuthor
  include JobDb::Addon::Release
  include JobDb::Addon::Sites
  include JobDb::Addon::Member::Admins
  include JobDb::Addon::GroupPermission

  set_permission_name "job_db_companies"

  seqid :id

  field :name, type: String #企業名
  field :kana, type: String #企業名フリガナ
  field :company_number, type: String #企業整理番号
  belongs_to_file :logo_image #企業ロゴ
  field :catchphrase, type: String #キャッチフレーズ

  belongs_to_file :profile_image #企業イメージ
  field :profile_image_caption, type: String #企業イメージ キャプション
  belongs_to_file :profile_image_small_1 #企業イメージ小１
  field :profile_image_small_1_caption, type: String #企業イメージ小１ キャプション
  belongs_to_file :profile_image_small_2 #企業イメージ小２
  field :profile_image_small_2_caption, type: String #企業イメージ小２ キャプション

  belongs_to :sector, class_name: "JobDb::Company::Sector" # 業種
  embeds_ids :work_areas, class_name: "JobDb::Company::Area" #勤務地
  embeds_ids :prefecture_certifications, class_name: "JobDb::Company::PrefectureCertification" #県認定

  permit_params :name
  permit_params :kana
  permit_params :company_number
  permit_params :in_logo_image
  permit_params :catchphrase
  permit_params :in_profile_image
  permit_params :profile_image_caption
  permit_params :in_profile_image_small_1
  permit_params :profile_image_small_1_caption
  permit_params :in_profile_image_small_2
  permit_params :profile_image_small_2_caption
  permit_params :sector_id
  permit_params work_area_ids: []
  permit_params prefecture_certification_ids: []

  validates :name, presence: true, length: { maximum: 40 }

  def sector_options
    sectors = []
    JobDb::Company::Sector.where(depth: 1).map do |s1|
      sectors << [ s1.filename, s1.id ]
      s1.children.each do |s2|
        sectors << [ "+---- #{s2.name}", s2.id ]
      end
    end
    sectors
  end

  class << self
    def search(parasm = {})
      # TODO: Implement
      all
    end
  end

  def filename
    id.to_s
  end

  def date
    released || updated || created
  end
end
