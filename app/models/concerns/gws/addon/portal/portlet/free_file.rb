module Gws::Addon::Portal::Portlet
  module FreeFile
    extend ActiveSupport::Concern
    extend SS::Addon
    include Gws::Addon::Model::File

    set_addon_type :gws_portlet

    included do
      after_clone_files :rewrite_file_urls
    end

    def rewrite_file_urls
      html = self.html
      return if html.blank?

      in_clone_file.each do |old_id, new_id|
        old_file = SS::File.find(old_id) rescue nil
        new_file = SS::File.find(new_id) rescue nil
        next if old_file.blank? || new_file.blank?

        html.gsub!("=\"#{old_file.url}\"", "=\"#{new_file.url}\"")
        html.gsub!("=\"#{old_file.thumb_url}\"", "=\"#{new_file.thumb_url}\"")
      end
      self.html = html
    end
  end
end
