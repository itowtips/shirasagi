class SiteAppender::Outer::Cms::Part
  include SS::Document

  store_in client: :outer, collection: :cms_parts

  def name
    self["name"]
  end

  def save_inner(site)
    item = SiteAppender::Inner::Cms::Part.new
    _old_id = id
    _old_created = created
    _old_updated = updated

    attributes.each do |k, v|
      item[k] = v
    end
    item["_id"] = nil
    item["_old_id"] = _old_id
    item.id = nil

    item["site_id"] = site.id

    item.save!(validate: false)
    item.set(created: _old_created)
    item.set(updated: _old_updated)
  end
end
