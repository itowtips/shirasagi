module Opendata::Addon::Harvest
  module Importer
    extend SS::Addon
    extend ActiveSupport::Concern
    include Opendata::Harvest::CkanApiImporter
    include Opendata::Harvest::ShirasagiApiImporter
    include Opendata::Harvest::ShirasagiScrapingImporter

    def put_log(message)
      Rails.logger.warn(message)
      puts message
    end

    def uploaded_sample_file(filename, format)
      path = "#{Rails.root}/spec/fixtures/opendata/dataset_import/resources/sample.#{format.downcase}"
      file = ::Fs::UploadedFile.create_from_file(path)
      file.original_filename = filename
      file
    end

    def get_license_from_key(key)
      @_license_from_key ||= {}
      return @_license_from_key[key] if @_license_from_key[key]

      @_license_from_key[key] = ::Opendata::License.site(site).in(ckan_license_keys: key).first
      put_log("could not found license #{key}") if @_license_from_key[key].nil?
      @_license_from_key[key]
    end

    def get_license_from_name(name)
      @_license_from_name ||= {}
      return @_license_from_name[name] if @_license_from_name[name]

      @_license_from_name[name] = ::Opendata::License.site(site).where(name: name).first
      put_log("could not found license #{name}") if @_license_from_name[name].nil?
      @_license_from_name[name]
    end

    def set_relation_ids(dataset)
      # category
      @_category_settings ||= begin
        h = {}
        category_settings.each do |setting|
          next if setting.category.nil?

          h[setting.category_id] ||= []
          h[setting.category_id] << setting
        end
        h
      end

      category_ids = []
      @_category_settings.each do |category_id, settings|
        settings.each do |setting|
          if setting.match?(dataset)
            category_ids << category_id
            break
          end
        end
      end
      category_ids = self.default_category_ids if category_ids.blank?
      dataset.category_ids = category_ids

      # estat category
      @_estat_category_settings ||= begin
        h = {}
        estat_category_settings.each do |setting|
          next if setting.category.nil?

          h[setting.category_id] ||= []
          h[setting.category_id] << setting
        end
        h
      end

      estat_category_ids = []
      @_estat_category_settings.each do |category_id, settings|
        settings.each do |setting|
          if setting.match?(dataset)
            estat_category_ids << category_id
            break
          end
        end
      end
      estat_category_ids = self.default_estat_category_ids if estat_category_ids.blank?
      dataset.estat_category_ids = estat_category_ids

      # area
      dataset.area_ids = self.default_area_ids
      put_log("- set category_ids #{dataset.category_ids.join(", ")} estat_category_ids #{dataset.estat_category_ids.join(", ")} area_ids #{dataset.area_ids.join(", ")}")

      dataset.save!
      dataset
    end

    def import
      if api_type == "ckan"
        import_from_ckan_api
      elsif api_type == "shirasagi_api"
        import_from_shirasagi_api
      elsif api_type == "shirasagi_scraper"
        import_from_shirasagi_scraper
      end
    end
  end
end
