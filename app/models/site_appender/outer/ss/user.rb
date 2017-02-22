class SiteAppender::Outer::SS::User
  include SS::Document

  store_in client: :outer, collection: :ss_users

  def name
    self["name"]
  end

  def save_inner(site)
    item = SiteAppender::Inner::SS::User.new
    _old_id = id
    _old_created = created
    _old_updated = updated

    attributes.each do |k, v|
      item[k] = v
    end
    item["_id"] = nil
    item["_old_id"] = _old_id
    item.id = nil

    item.save!(validate: false)
    item.set(created: _old_created)
    item.set(updated: _old_updated)
  end
end
