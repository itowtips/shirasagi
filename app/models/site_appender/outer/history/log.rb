class SiteAppender::Outer::History::Log
  include SS::Document

  store_in client: :outer, collection: :history_logs

  def name
    self["id"]
  end

  def save_inner(site)
    item = SiteAppender::Inner::History::Log.new
    _old_id = id
    _old_created = created
    _old_updated = updated

    attributes.each do |k, v|
      item[k] = v
    end
    item["_old_id"] = _old_id
    item["site_id"] = site.id

    item.save!(validate: false)
    item.set(created: _old_created)
    item.set(updated: _old_updated)
  end
end
