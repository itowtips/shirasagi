class SiteAppender::Inner::History::Log
  include SS::Document
  include SiteAppender::FixRelation

  store_in collection: :history_logs

  field :_old_id, type: BSON::ObjectId

  default_scope ->{ where(:_old_id.exists => true) }

  def fix_relation_target_id(item)
    old_id = item.target_id.to_i
    new_id = item.target_class.constantize.where(_old_id: old_id).first.id rescue nil

    item.set("target_id" => new_id) if new_id
  end

  def becomes_with_inner_id
    item = History::Log.find(id)
    if item.respond_to?(:becomes_with_route)
      item.becomes_with_route
    else
      item
    end
  end

  def name
    self["id"]
  end
end
