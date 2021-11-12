module Pippi::Joruri::Importer
  class Base
    attr_reader :site, :joruri_host, :joruri_base_url, :csv_path

    def initialize(site)
      @site = site
      @joruri_host = "www.hamamatsu-pippi.net"
      @joruri_base_url = "https://www.hamamatsu-pippi.net"
      @csv_path = ::File.join(Rails.root, "lib/tasks/pippi/joruri")
    end
  end
end
