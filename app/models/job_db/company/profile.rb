# 企業情報
class JobDb::Company::Profile
  extend SS::Translation
  include SS::Document
  include JobDb::Company::TemplateVariable
  include JobDb::Addon::Release
  include JobDb::Addon::Member::Admins
  include JobDb::Addon::GroupPermission

  set_permission_name "job_db_companies"

  seqid :id
  field :name, type: String

  permit_params :name

  validates :name, presence: true, length: { maximum: 40 }

  class << self
    def site(site, opts = {})
      if opts[:state].present?
        self.in(group_ids: Cms::Group.unscoped.site(site).state(opts[:state]).pluck(:id))
      else
        self.in(group_ids: Cms::Group.site(site).pluck(:id))
      end
    end

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
