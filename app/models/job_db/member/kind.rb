# メンバー種別
class JobDb::Member::Kind
  extend SS::Translation
  include SS::Document
  include JobDb::Addon::GroupPermission

  set_permission_name "job_db_members"

  # seqid :id
  replace_field "_id", String
  field :name, type: String
  permit_params :_id, :name
  validates :_id, presence: true, length: { maximum: 20 }, format: { with: /\A[A-Za-z0-9_\-]+\z/ }
  validates :name, presence: true, length: { maximum: 40 }

  class << self
    def search(params = {})
      all
    end
  end
end
