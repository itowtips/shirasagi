module Pippi::Hamasuku
  module Cms
    class Page
      include ::SS::Document
      store_in client: :hamasuku, collection: :cms_pages

      def filename
        self["filename"]
      end

      def full_url
        "https://www.hamasuku.com/#{filename}"
      end
    end
  end
end
