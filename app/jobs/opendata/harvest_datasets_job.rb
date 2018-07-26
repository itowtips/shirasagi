class Opendata::HarvestDatasetsJob < Cms::ApplicationJob
  def perform(importer_id)
    if importer_id
      Opendata::Harvest.find(importer_id).import
    else
      Opendata::Harvest.site(site).each do |importer|
        importer.import
      end
    end
  end
end
