class Member::Group
  extend SS::Translation
  include SS::Document
  include SS::Reference::Site
  include Cms::SitePermission

  set_permission_name :cms_users, :edit

  seqid :id, init: 100
  field :name, type: String
  embeds_many :members, class_name: "Member::GroupMember", cascade_callbacks: true

  permit_params :name

  class << self
    def search(params = {})
      criteria = self.where({})
      return criteria if params.blank?

      if params[:name].present?
        criteria = criteria.search_text params[:name]
      end
      if params[:keyword].present?
        criteria = criteria.keyword_in params[:keyword], :name
      end
      criteria
    end
  end
end
