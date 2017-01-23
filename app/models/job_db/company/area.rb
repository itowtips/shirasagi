# 地区
class JobDb::Company::Area
  extend SS::Translation
  include SS::Document
  #include Sys::Permission
  include JobDb::Addon::GroupPermission

  set_permission_name "job_db_companies", :edit

  seqid :id
  field :name, type: String
  field :filename, type: String
  field :depth, type: Integer
  field :order, type: Integer

  belongs_to :parent, class_name: "JobDb::Company::Area", inverse_of: :children
  has_many :children, class_name: "JobDb::Company::Area", dependent: :destroy, inverse_of: :parent,
    order: { order: 1 }

  permit_params :name, :order

  validate :validate_name

  before_validation :set_filename

  default_scope -> { order_by(order: 1, name: 1) }

  def validate_name
    if name.blank?
      errors.add :name, :invalid
      return
    end

    if name.size > 40 || name =~ /\//
      errors.add :name, :invalid
      return
    end
  end

  def set_filename
    self.filename = parent ? "#{parent.name}/#{name}" : name
  end

  class << self
    def search(params = {})
      criteria = self.where({})
      return criteria if params.blank?

      if params[:name].present?
        criteria = criteria.search_text params[:name]
      end
      criteria
    end
  end
end
