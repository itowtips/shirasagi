class SiteAppender::Inner::Cms::Role
  include SS::Document
  include SiteAppender::FixRelation

  store_in collection: :cms_roles

  seqid :id
  field :_old_id, type: Integer

  default_scope ->{ where(:_old_id.exists => true) }

  def becomes_with_inner_id
    item = Cms::Role.find(id)
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
