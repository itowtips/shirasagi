module Riken::Payment
  class WorkflowSample
    include SS::Document
    include Gws::Referenceable
    include Gws::Reference::User
    include Gws::Reference::Site
    include Riken::Addon::Payment::WorkflowSample
    include Gws::SitePermission

    set_permission_name "gws_groups", :edit

    seqid :id
    field :name, type: String
    permit_params :name

    validates :name, presence: true

    default_scope ->{ order_by(workflow_id: 1) }

    class << self
      def search(params = {})
        criteria = all
        return criteria if params.blank?

        if params[:keyword].present?
          criteria = criteria.keyword_in(params[:keyword], :name)
        end

        criteria
      end
    end
  end
end
