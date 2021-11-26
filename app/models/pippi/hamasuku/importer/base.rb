module Pippi::Hamasuku::Importer
  class Base
    attr_reader :site
    attr_reader :hamasuku_host, :hamasuku_base_url, :hamasuku_site_id
    attr_reader :joruri_host, :joruri_base_url

    def initialize(site)
      @site = site
      @hamasuku_host = "www.hamasuku.com"
      @hamasuku_base_url = "https://www.hamasuku.com/"
      @hamasuku_site_id = 1

      @joruri_host = "www.hamamatsu-pippi.net"
      @joruri_base_url = "https://www.hamamatsu-pippi.net"
    end
  end
end
