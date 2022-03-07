module Gws::Addon::Portal::Portlet
  module AdFile
    extend ActiveSupport::Concern
    extend SS::Addon

    set_addon_type :gws_portlet

    DEFAULT_AD_FILE_LIMIT = 5

    included do
      attr_accessor :link_urls
      attr_accessor :in_clone_ad_file

      embeds_ids :ad_files, class_name: "SS::File"
      permit_params ad_file_ids: [], link_urls: {}

      validate :validate_ad_files_limit

      before_save :clone_ad_files, if: ->{ in_clone_ad_file }
      before_save :save_ad_files
      after_destroy :destroy_ad_files

      define_model_callbacks :clone_ad_files
    end

    module ClassMethods
      def ad_file_limit
        limit = SS.config.gws.portal["portlet_settings"]["ad"]["image_limit"].to_i
        if limit <= 0
          limit = DEFAULT_AD_FILE_LIMIT
        end

        limit
      end
    end

    private

    def save_ad_files
      ids = []
      self.link_urls ||= {}
      ad_files.each do |file|
        file = file.becomes_with(SS::LinkFile)
        file.update!(
          site_id: site_id, model: model_name.i18n_key, state: "closed", owner_item: self,
          link_url: self.link_urls[file.id.to_s]
        )
        ids << file.id
      end
      self.ad_file_ids = ids

      del_ids = ad_file_ids_was.to_a - ids
      SS::LinkFile.all.unscoped.in(id: del_ids).destroy_all
    end

    def destroy_ad_files
      SS::LinkFile.all.unscoped.in(id: ad_file_ids).destroy_all
    end

    def validate_ad_files_limit
      limit = self.class.ad_file_limit
      if ad_files.count > limit
        errors.add :ad_files, :too_many_files, limit: limit
      end
    end

    def clone_ad_files
      run_callbacks(:clone_ad_files) do
        ids = {}
        self.link_urls ||= {}
        ad_files.each do |f|
          attributes = Hash[f.attributes]
          link_url = attributes["link_url"]
          attributes.slice!(*f.fields.keys)

          file = SS::File.new(attributes)
          file.id = nil
          file.in_file = f.uploaded_file
          file.user_id = @cur_user.id if @cur_user
          file.owner_item = self if file.respond_to?(:owner_item=)

          file.save validate: false
          ids[f.id] = file.id
          self.link_urls[file.id] = link_url
        end
        self.ad_file_ids = ids.values
        self.in_clone_ad_file = ids
      end
    end
  end
end
