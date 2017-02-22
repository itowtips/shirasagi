class SiteAppender::Inner::History::Backup
  include SS::Document
  include SiteAppender::FixRelation

  store_in collection: :history_backups

  field :_old_id, type: BSON::ObjectId

  default_scope ->{ where(:_old_id.exists => true) }

  # support data["_id"] and data["site_id"] only
  def fix_data_hash_id(site)
    item = becomes_with_inner_id

    data = item.data
    old_id = data["_id"]
    new_id = item.ref_class.constantize.where(_old_id: old_id).first.id rescue nil

    if new_id
      data["_id"] = new_id
      data["site_id"] = site.id
      item.set("data" => data)
      puts " data.id #{old_id} #{new_id}"
    end
  end

  def becomes_with_inner_id
    item = History::Backup.find(id)
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
