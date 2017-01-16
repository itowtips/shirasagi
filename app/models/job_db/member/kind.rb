# メンバー種別
class JobDb::Member::Kind
  extend SS::Translation
  include SS::Document
  include Sys::Permission

  set_permission_name "job_db_members", :edit

  seqid :id
  field :name, type: String
  permit_params :name
  validates :name, presence: true, length: { maximum: 40 }
end
