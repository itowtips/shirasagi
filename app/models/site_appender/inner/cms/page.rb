class SiteAppender::Inner::Cms::Page
  include SS::Document
  include SiteAppender::FixRelation

  store_in collection: :cms_pages

  seqid :id
  field :_old_id, type: Integer

  default_scope ->{ where(:_old_id.exists => true) }

  def fix_workflow_approvers
    item = becomes_with_inner_id
    return unless item.respond_to?(:workflow_approvers)
    return if item.workflow_approvers.blank?

    new_approvers = []
    item.workflow_approvers.each do |v|
      old_id = v[:user_id]
      new_id = SiteAppender::Inner::SS::User.where(_old_id: old_id).first.id rescue nil

      v[:user_id] = new_id if new_id
      new_approvers << v
    end

    puts " workflow_approvers #{item.workflow_approvers} #{new_approvers}"
    item.set("workflow_approvers" => new_approvers)
  end

  def becomes_with_inner_id
    item = Cms::Page.find(id)
    if item.respond_to?(:becomes_with_route)
      item.becomes_with_route
    else
      item
    end
  end

  def name
    self["name"]
  end
end
