# 企業情報
class JobDb::Company::Profile
  extend SS::Translation
  include SS::Document
  include JobDb::Addon::Member::Admins
  include Sys::Permission

  set_permission_name "job_db_companies", :edit

  seqid :id
  field :name, type: String

  permit_params :name

  validates :name, presence: true, length: { maximum: 40 }

  class << self
    def search(parasm = {})
      all
    end
  end
end
