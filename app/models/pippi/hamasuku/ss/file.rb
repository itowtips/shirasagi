module Pippi::Hamasuku
  module SS
    class File
      include ::SS::Document
      store_in client: :hamasuku, collection: :ss_files

      def filename
        self["filename"]
      end

      def url
        "/fs/" + id.to_s.split(//).join("/") + "/_/#{filename}"
      end

      def name
        self["name"]
      end

      def path
        idpath = "/private/files/ss_files/" + id.to_s.split(//).join("/") + "/_/#{id}"
        ::File.join(::File.dirname(Rails.root.to_s), "ss-hamasuku", idpath)
      end
    end
  end
end
