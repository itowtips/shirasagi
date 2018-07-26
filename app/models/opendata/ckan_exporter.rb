class Opendata::CkanExporter
  include SS::Document
  include SS::Reference::User
  include SS::Reference::Site
  include Cms::Reference::Node
  include Cms::Addon::GroupPermission
  include ActiveSupport::NumberHelper

  set_permission_name "opendata_harvests", :edit

  seqid :id

  field :name, type: String
  field :url, type: String
  field :api_key, type: String
  field :order, type: Integer, default: 0

  field :host, type: String

  field :stored_datasets, type: Hash, default: {}
  field :stored_resources, type: Hash, default: {}

  validates :name, presence: true
  validates :url, presence: true
  validates :api_key, presence: true
  validate :validate_host, if: -> { url.present? }

  permit_params :name, :url, :api_key, :order

  default_scope -> { order_by(order: 1) }

  private

  def validate_host
    begin
      self.host = ::URI.parse(url).host
    rescue => e
      errors.add :host, :invalid
    end
  end

  public

  def order
    value = self[:order].to_i
    value < 0 ? 0 : value
  end

  def dataset_purge
    package = ::Opendata::Harvest::CkanPackage.new(url)

    list = package.package_list
    list.each_with_index do |name, idx|
      dataset_attributes = package.package_show(name)
      id = dataset_attributes["id"]

      puts "#{idx + 1} : dataset_purge #{name} #{id}"
      package.dataset_purge(id, api_key)
    end

    self.stored_datasets = {}
    self.stored_resources = {}
    save!
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
          result = package.package_update(
            stored_dataset_id,
            dataset_create_params(dataset),
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
          result = package.package_update(
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
              p stored_resource_id
              exported_resources[resource.uuid] = stored_resource_id

              result = package.resource_update(
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
              result =package.resource_update(
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
      package.resource_delete(id, api_key)
    end

    # destroy unimported datasets
    (stored_datasets.values - exported_datasets.values).each do |id|
      package.dataset_purge(id, api_key)
    end

    self.stored_resources = exported_resources
    self.stored_datasets = exported_datasets
    save!
  end

  def dataset_create_params(dataset)
    {
      name: dataset.uuid,
      title: dataset.name,
      notes: dataset.text,
      owner_org: "d2b2018d-c7ab-4c63-ad1c-0cf28027559a",
      metadata_created: dataset.created.utc.strftime('%Y-%m-%d %H:%M:%S'), # not accepted
      metadata_modified: dataset.updated.utc.strftime('%Y-%m-%d %H:%M:%S') # not accepted
    }
  end

  def dataset_update_params(dataset)
    {
      name: dataset.uuid,
      title: dataset.name,
      notes: dataset.text,
      owner_org: "d2b2018d-c7ab-4c63-ad1c-0cf28027559a",
      metadata_created: dataset.created.utc.strftime('%Y-%m-%d %H:%M:%S'),
      metadata_modified: dataset.updated.utc.strftime('%Y-%m-%d %H:%M:%S')
    }
  end

  def resource_create_params(resource)
    {
      name: resource.filename,
      url: (resource.file ? resource.file.filename : resource.source_url),
      description: resource.text,
      format: resource.format,
      created: resource.created.utc.strftime('%Y-%m-%d %H:%M:%S'),
      last_modified: resource.updated.utc.strftime('%Y-%m-%d %H:%M:%S'), # not accepted
      revision_id: resource.revision_id, # not accepted
    }
  end

  def resource_update_params(resource)
    {
      name: resource.filename,
      url: (resource.file ? resource.file.filename : resource.source_url),
      description: resource.text,
      format: resource.format,
      created: resource.created.utc.strftime('%Y-%m-%d %H:%M:%S'),
      last_modified: resource.updated.utc.strftime('%Y-%m-%d %H:%M:%S'),
      revision_id: resource.revision_id, # not accepted
    }
  end
end

