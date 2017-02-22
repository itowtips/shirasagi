class SiteAppender::Outer::SS::File
  include SS::Model::File
  include SS::Relation::Thumb

  store_in client: :outer, collection: :ss_files

  cattr_accessor(:root, instance_accessor: false) { nil }

  def name
    self["name"]
  end

  def old_in_file
    uploaded_file
  end

  def save_inner(site)
    item = SiteAppender::Inner::SS::File.new
    _old_id = id
    _old_created = created
    _old_updated = updated

    attributes.each do |k, v|
      item[k] = v
    end
    item["_id"] = nil
    item["_old_id"] = _old_id
    item.id = nil

    item.site_id = site.id
    item.in_file = old_in_file

    item.save!(validate: false)
    item.set(created: _old_created)
    item.set(updated: _old_updated)
  end
end
