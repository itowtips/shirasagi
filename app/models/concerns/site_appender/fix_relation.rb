module SiteAppender::FixRelation
  extend ActiveSupport::Concern
  extend SS::Translation

  def fix_inner_relations
    item = becomes_with_inner_id
    item.fields.select { |name| name =~ /^.+_ids?$/ }.each do |f|
      name = f[0]

      #begin
        old_id = item.send(name)
        send("fix_relation_#{name}", item)
        new_id = item.send(name)

        if new_id.present?
          puts " #{name} #{old_id} #{new_id ? new_id : "?"}"
        end
      #rescue => e
      #  puts "#{e.class} #{item.class} #{name}"
      #end
    end
  end

  ## page
  def fix_relation_site_id(item)
    # skip
  end

  def fix_relation_user_id(item)
    fix_inner_relation_id(item, "user_id", SiteAppender::Inner::SS::User)
  end

  def fix_relation_group_ids(item)
    fix_inner_relation_ids(item, "group_ids", SiteAppender::Inner::SS::Group)
  end

  def fix_relation_layout_id(item)
    fix_inner_relation_id(item, "layout_id", SiteAppender::Inner::Cms::Layout)
  end

  def fix_relation_body_layout_id(item)
    # not implemented
  end

  def fix_relation_category_ids(item)
    fix_inner_relation_ids(item, "category_ids", SiteAppender::Inner::Cms::Node)
  end

  def fix_relation_lock_owner_id(item)
    item.set("lock_owner_id" => nil)
  end

  def fix_relation_master_id(item)
    fix_inner_relation_id(item, "master_id", SiteAppender::Inner::Cms::Page)
  end

  def fix_relation_workflow_user_id(item)
    fix_inner_relation_id(item, "workflow_user_id", SiteAppender::Inner::SS::User)
  end

  def fix_relation_workflow_member_id(item)
    #  not implemented
  end

  def fix_relation_file_ids(item)
    fix_inner_relation_ids(item, "file_ids", SiteAppender::Inner::SS::File)
  end

  def fix_relation_related_page_ids(item)
    fix_inner_relation_ids(item, "related_page_ids", SiteAppender::Inner::Cms::Page)
  end

  def fix_relation_contact_group_id(item)
    fix_inner_relation_id(item, "contact_group_id", SiteAppender::Inner::SS::Group)
  end

  def fix_relation_file_id(item)
    fix_inner_relation_id(item, "file_id", SiteAppender::Inner::SS::File)
  end

  def fix_relation_ads_category_ids(item)
    fix_inner_relation_id(item, "ads_category_ids", SiteAppender::Inner::Cms::Node)
  end

  def fix_relation_opendata_dataset_ids(item)
    #  not implemented
  end

  def fix_relation_opendata_category_ids(item)
    #  not implemented
  end

  def fix_relation_opendata_area_ids(item)
    #  not implemented
  end

  def fix_relation_opendata_dataset_ids(item)
    #  not implemented
  end

  def fix_relation_opendata_dataset_group_ids(item)
    #  not implemented
  end

  def fix_relation_opendata_license_ids(item)
    #  not implemented
  end

  ## node
  def fix_relation_page_layout_id(item)
    fix_inner_relation_id(item, "page_layout_id", SiteAppender::Inner::Cms::Layout)
  end

  def fix_relation_st_category_ids(item)
    fix_inner_relation_ids(item, "st_category_ids", SiteAppender::Inner::Cms::Node)
  end

  def fix_relation_service_ids(item)
    fix_inner_relation_ids(item, "service_ids", SiteAppender::Inner::Cms::Node)
  end

  def fix_relation_st_service_ids(item)
    fix_inner_relation_ids(item, "st_service_ids", SiteAppender::Inner::Cms::Node)
  end

  def fix_relation_location_ids(item)
    fix_inner_relation_ids(item, "location_ids", SiteAppender::Inner::Cms::Node)
  end

  def fix_relation_st_location_ids(item)
    fix_inner_relation_ids(item, "st_location_ids", SiteAppender::Inner::Cms::Node)
  end

  def fix_relation_search_node_id(item)
    fix_inner_relation_id(item, "search_node_id", SiteAppender::Inner::Cms::Node)
  end

  def fix_relation_urgency_default_layout_id(item)
    fix_inner_relation_id(item, "urgency_default_layout_id", SiteAppender::Inner::Cms::Layout)
  end

  def fix_relation_opendata_site_ids(item)
    #  not implemented
  end

  ## group
  def fix_relation_ldap_import_id(item)
    #  not implemented
  end

  ## user
  def fix_relation_title_ids(item)
    #  not implemented
  end

  def fix_relation_sys_role_ids(item)
    item.set("sys_role_ids" => [])
  end

  def fix_relation_cms_role_ids(item)
    fix_inner_relation_ids(item, "cms_role_ids", SiteAppender::Inner::Cms::Role)
  end

  ## inquiry answer
  def fix_relation_node_id(item)
    fix_inner_relation_id(item, "node_id", SiteAppender::Inner::Cms::Node)
  end

  ##
  def fix_inner_relation_id(item, key, klass)
    old_id = item.send(key)
    return if old_id.blank?

    new_id = klass.where(_old_id: old_id).first.id rescue nil
    item.set(key => new_id)
  end

  def fix_inner_relation_ids(item, key, klass)
    old_ids = item.send(key)
    return if old_ids.blank?

    new_ids = []
    old_ids.each do |old_id|
      new_ids << klass.where(_old_id: old_id).first.id rescue nil
    end
    new_ids = new_ids.compact
    item.set(key => new_ids)
  end
end
