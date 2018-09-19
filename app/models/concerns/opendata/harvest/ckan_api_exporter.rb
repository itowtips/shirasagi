module Opendata::Harvest::CkanApiExporter
  extend ActiveSupport::Concern

  def put_log(message)
    Rails.logger.warn(message)
    puts message
  end

  def dataset_purge
    package = ::Opendata::Harvest::CkanPackage.new(url)

    list = package.package_list
    list.each_with_index do |name, idx|
      dataset_attributes = package.package_show(name)
      id = dataset_attributes["id"]

      put_log "#{idx + 1} : dataset_purge #{name} #{id}"
      package.dataset_purge(id, api_key)
    end

    self.stored_datasets = {}
    self.stored_resources = {}
    save!
  end

  def group_list
    package = ::Opendata::Harvest::CkanPackage.new(url)

    list = package.group_list
    list.each_with_index do |name, idx|
      group_attributes = package.group_show(name)
      put_log "#{group_attributes["id"]} #{group_attributes["name"]} #{group_attributes["title"]}"
    end
  end

  def initialize_group
    package = ::Opendata::Harvest::CkanPackage.new(url)
    list = package.group_list
    list.each_with_index do |name, idx|
      put_log "delete #{name}"
      package.group_purge(name, api_key)
    end

    group_settings.destroy_all

    idx = 0
    Opendata::Node::Category.site(site).where(depth: 3).each do |c|
      params = { name: "ssg#{c.id}", title: "静岡県-#{c.name}" }
      attributes = package.group_create(params, api_key)
      put_log "#{attributes["id"]} #{attributes["name"]} #{attributes["title"]}"

      setting = Opendata::Harvest::Exporter::GroupSetting.new(exporter: self, cur_site: site)
      setting.name = attributes["title"]
      setting.ckan_id = attributes["id"]
      setting.order = (idx + 1) * 10
      setting.category_ids = [c.id]
      setting.save!

      idx += 1
    end

    Opendata::Node::EstatCategory.site(site).where(depth: 3).each do |c|
      params = { name: "ssg#{c.id}", title: "e-Stat分類-#{c.name}" }
      attributes = package.group_create(params, api_key)
      put_log "#{attributes["id"]} #{attributes["name"]} #{attributes["title"]}"

      setting = Opendata::Harvest::Exporter::GroupSetting.new(exporter: self, cur_site: site)
      setting.name = attributes["title"]
      setting.ckan_id = attributes["id"]
      setting.order = (idx + 1) * 10
      setting.estat_category_ids = [c.id]
      setting.save!

      idx += 1
    end
  end

  def organization_list
    package = ::Opendata::Harvest::CkanPackage.new(url)

    list = package.organization_list
    list.each_with_index do |name, idx|
      attributes = package.organization_show(name)
      put_log "#{attributes["id"]} #{attributes["name"]} #{attributes["title"]}"
    end
  end

  def initialize_organization
    package = ::Opendata::Harvest::CkanPackage.new(url)
    list = package.organization_list
    list.each_with_index do |name, idx|
      put_log "delete #{name}"
      package.organization_purge(name, api_key)
    end

    owner_org_settings.destroy_all

    SS::Group.each_with_index do |g, idx|
      next if g.depth != 1

      params = { name: "org#{g.id}", title: "静岡県 #{g.trailing_name}" }
      attributes = package.organization_create(params, api_key)
      put_log "#{attributes["id"]} #{attributes["name"]} #{attributes["title"]}"

      setting = Opendata::Harvest::Exporter::OwnerOrgSetting.new(exporter: self, cur_site: site)
      setting.name = attributes["title"]
      setting.ckan_id = attributes["id"]
      setting.order = (idx + 1) * 10
      setting.group_ids = [g.id]
      setting.save!
    end
  end

  def export
    package = ::Opendata::Harvest::CkanPackage.new(url)
    exported_datasets = {}
    exported_resources = {}

    dataset_ids = Opendata::Dataset.where(filename: /^#{node.filename}\//, depth: node.depth + 1).
        and_public.pluck(:id)

    dataset_ids.each do |dataset_id|
      dataset = Opendata::Dataset.find(dataset_id) rescue nil
      next unless dataset

      begin
        if stored_datasets[dataset.uuid]

          stored_dataset_id = stored_datasets[dataset.uuid]
          exported_datasets[dataset.uuid] = stored_dataset_id

          puts "update dataset #{dataset.name} #{dataset.uuid}"
          result = package.package_patch(
            stored_dataset_id,
            dataset_update_params(dataset),
            api_key
          )

        else

          puts "create dataset #{dataset.name} #{dataset.uuid}"
          #result = package.dataset_purge(dataset.uuid, api_key)

          # create dataset
          result = package.package_create(
            dataset_create_params(dataset),
            api_key
          )
          stored_dataset_id = result["id"]
          exported_datasets[dataset.uuid] = stored_dataset_id

          # update dataset metadata_created, modified
          result = package.package_patch(
            stored_dataset_id,
            dataset_update_params(dataset),
            api_key
          )
        end

        dataset.resources.each do |resource|
          begin
            if stored_resources[resource.uuid]

              puts "update resource #{resource.name} #{resource.uuid}"

              stored_resource_id = stored_resources[resource.uuid]
              exported_resources[resource.uuid] = stored_resource_id

              result = package.resource_patch(
                stored_resource_id,
                resource_update_params(resource),
                api_key,
                resource.file
              )

            else

              puts "create resource #{resource.name} #{resource.uuid}"

              # create resource
              result = package.resource_create(
                stored_dataset_id,
                resource_create_params(resource),
                api_key,
                resource.file
              )

              stored_resource_id = result["id"]
              exported_resources[resource.uuid] = stored_resource_id

              # update resource last_modified
              result =package.resource_patch(
                stored_resource_id,
                resource_update_params(resource),
                api_key
              )

            end
          rescue => e
            message = "#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}"
            puts message
          end
        end

      rescue => e
        message = "#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}"
        puts message
      end
    end

  ensure
    # destroy unimported resourcse
    (stored_resources.values - exported_resources.values).each do |id|
      puts "delete resource #{id}"
      package.resource_delete(id, api_key)
    end

    # destroy unimported datasets
    (stored_datasets.values - exported_datasets.values).each do |id|
      puts "purge dataset #{id}"
      package.dataset_purge(id, api_key)
    end

    self.stored_resources = exported_resources
    self.stored_datasets = exported_datasets
    save!
  end

  def dataset_owner_org(dataset)
    owner_org = nil
    owner_org_settings.each do |setting|
      owner_org = setting.ckan_id if setting.match?(dataset)
    end
    owner_org
  end

  def dataset_groups(dataset)
    groups = []
    group_settings.each do |setting|
      groups << { id: setting.ckan_id } if setting.match?(dataset)
    end
    groups
  end

  def dataset_create_params(dataset)
    params = {
      name: dataset.uuid,
      title: dataset.name,
      notes: dataset.text,
      metadata_created: dataset.created.utc.strftime('%Y-%m-%d %H:%M:%S'), # not accepted
      metadata_modified: dataset.updated.utc.strftime('%Y-%m-%d %H:%M:%S') # not accepted
    }
    owner_org = dataset_owner_org(dataset)
    groups = dataset_groups(dataset)

    params[:owner_org] = owner_org if owner_org.present?
    params[:groups] = groups if groups.present?
    params
  end

  def dataset_update_params(dataset)
    params = {
      name: dataset.uuid,
      title: dataset.name,
      notes: dataset.text,
      metadata_created: dataset.created.utc.strftime('%Y-%m-%d %H:%M:%S'),
      metadata_modified: dataset.updated.utc.strftime('%Y-%m-%d %H:%M:%S')
    }
    owner_org = dataset_owner_org(dataset)
    groups = dataset_groups(dataset)

    params[:owner_org] = owner_org if owner_org.present?
    params[:groups] = groups if groups.present?
    params
  end

  def resource_create_params(resource)
    params = {
      name: resource.filename,
      url: (resource.file ? resource.file.filename : resource.source_url),
      description: resource.text,
      format: resource.format,
      created: resource.created.utc.strftime('%Y-%m-%d %H:%M:%S'),
      last_modified: resource.updated.utc.strftime('%Y-%m-%d %H:%M:%S'), # not accepted
      revision_id: resource.revision_id, # not accepted
    }
    params
  end

  def resource_update_params(resource)
    params = {
      name: resource.filename,
      url: (resource.file ? resource.file.filename : resource.source_url),
      description: resource.text,
      format: resource.format,
      created: resource.created.utc.strftime('%Y-%m-%d %H:%M:%S'),
      last_modified: resource.updated.utc.strftime('%Y-%m-%d %H:%M:%S'),
      revision_id: resource.revision_id, # not accepted
    }
    params
  end
end
