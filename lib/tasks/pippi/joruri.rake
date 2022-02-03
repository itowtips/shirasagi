namespace :pippi do
  namespace :joruri do
    task import_nodes: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Node.new(site)
      importer.import_nodes
    end

    task import_hint_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Blog.new(site)
      importer.import_hint_docs
    end

    task restore_relations_hint_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Blog.new(site)
      importer.restore_relations_hint_docs
    end

    task destroy_hint_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Blog.new(site)
      importer.destroy_hint_docs
    end

    task import_bousai_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Blog.new(site)
      importer.import_bousai_docs
    end

    task restore_relations_bousai_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Blog.new(site)
      importer.restore_relations_bousai_docs
    end

    task destroy_bousai_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Blog.new(site)
      importer.destroy_bousai_docs
    end

    task import_report_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Report.new(site)
      importer.import_report_docs
    end

    task restore_relations_report_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Report.new(site)
      importer.restore_relations_report_docs
    end

    task destroy_report_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Report.new(site)
      importer.destroy_report_docs
    end

    task import_circles: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Circle.new(site)
      importer.import_circles
    end

    task destroy_circles: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Circle.new(site)
      importer.destroy_circles
    end

    task import_seminars: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Seminar.new(site)
      importer.import_seminars
    end

    task destroy_seminars: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Seminar.new(site)
      importer.destroy_seminars
    end

    task import_groups: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::User.new(site)
      importer.import_groups
    end

    task import_users: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::User.new(site)
      importer.import_users
    end

    task import_map_libraries: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Library.new(site)
      importer.import_map_libraries
    end

    task destroy_map_libraries: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Library.new(site)
      importer.destroy_map_libraries
    end

    task import_map_hiroba: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Hiroba.new(site)
      importer.import_map_hiroba
    end

    task destroy_map_hiroba: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Hiroba.new(site)
      importer.destroy_map_hiroba
    end

    task import_map_bunka: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Bunka.new(site)
      importer.import_map_bunka
    end

    task destroy_map_bunka: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Bunka.new(site)
      importer.destroy_map_bunka
    end

    task import_map_park: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Park.new(site)
      importer.import_map_park
    end

    task destroy_map_park: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Park.new(site)
      importer.destroy_map_park
    end

    task import_odekake_author_categories: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Odekake.new(site)
      importer.import_odekake_author_categories
    end

    task import_odekake_authors: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Odekake.new(site)
      importer.import_odekake_authors
    end

    task destroy_odekake_authors: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Odekake.new(site)
      importer.destroy_authors
    end

    task import_odekake_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Odekake.new(site)
      importer.import_odekake_docs
    end

    task restore_relations_odekake_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Odekake.new(site)
      importer.restore_relations_odekake_docs
    end

    task destroy_odekake_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Odekake.new(site)
      importer.destroy_odekake_docs
    end

    task import_pippi_contents: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::PippiContent.new(site)
      importer.import_pippi_contents
    end

    task restore_relations_pippi_contents: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::PippiContent.new(site)
      importer.restore_relations_pippi_contents
    end

    task destroy_pippi_contents: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::PippiContent.new(site)
      importer.destroy_pippi_contents
    end

    task import_facility_sho_koku_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::ShoKoku.new(site)
      importer.import_facility_sho_koku_docs
    end

    task destroy_facility_sho_koku_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::ShoKoku.new(site)
      importer.destroy_facility_sho_koku_docs
    end

    task import_facility_sho_shi_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::ShoShi.new(site)
      importer.import_facility_sho_shi_docs
    end

    task destroy_facility_sho_shi_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::ShoShi.new(site)
      importer.destroy_facility_sho_shi_docs
    end

    task import_facility_sho_watakushi_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::ShoWatakushi.new(site)
      importer.import_facility_sho_watakushi_docs
    end

    task destroy_facility_sho_watakushi_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::ShoWatakushi.new(site)
      importer.destroy_facility_sho_watakushi_docs
    end

    task import_facility_sho_tokubetsu_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::ShoTokubetsu.new(site)
      importer.import_facility_sho_tokubetsu_docs
    end

    task destroy_facility_sho_tokubetsu_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::ShoTokubetsu.new(site)
      importer.destroy_facility_sho_tokubetsu_docs
    end

    task import_facility_gakushushien_gakusyukyoshitsu_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::GakushushienGakusyukyoshitsu.new(site)
      importer.import_facility_gakushushien_gakusyukyoshitsu_docs
    end

    task destroy_facility_gakushushien_gakusyukyoshitsu_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::GakushushienGakusyukyoshitsu.new(site)
      importer.destroy_facility_gakushushien_gakusyukyoshitsu_docs
    end

    task import_facility_gakushushien_gakusyushien_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::GakushushienGakusyushien.new(site)
      importer.import_facility_gakushushien_gakusyushien_docs
    end

    task destroy_facility_gakushushien_gakusyushien_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::GakushushienGakusyushien.new(site)
      importer.destroy_facility_gakushushien_gakusyushien_docs
    end

    task import_facility_kodomoshokudo_kodomoshokudo_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::KodomoshokudoKodomoshokudo.new(site)
      importer.import_facility_kodomoshokudo_kodomoshokudo_docs
    end

    task destroy_facility_kodomoshokudo_kodomoshokudo_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::KodomoshokudoKodomoshokudo.new(site)
      importer.destroy_facility_kodomoshokudo_kodomoshokudo_docs
    end

    task import_facility_gakudo_houkagojidoukai_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::GakudoHoukagojidoukai.new(site)
      importer.import_facility_gakudo_houkagojidoukai_docs
    end

    task destroy_facility_gakudo_houkagojidoukai_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::GakudoHoukagojidoukai.new(site)
      importer.destroy_facility_gakudo_houkagojidoukai_docs
    end

    task import_facility_gakudo_ruijihoukagojidoukurabu_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::GakudoRuijihoukagojidoukurabu.new(site)
      importer.import_facility_gakudo_ruijihoukagojidoukurabu_docs
    end

    task destroy_facility_gakudo_ruijihoukagojidoukurabu_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::GakudoRuijihoukagojidoukurabu.new(site)
      importer.destroy_facility_gakudo_ruijihoukagojidoukurabu_docs
    end

    task import_facility_gakudo_sonotagakudouhoiku_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::GakudoSonotagakudouhoiku.new(site)
      importer.import_facility_gakudo_sonotagakudouhoiku_docs
    end

    task destroy_facility_gakudo_sonotagakudouhoiku_docs: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Joruri::Importer::Facility::GakudoSonotagakudouhoiku.new(site)
      importer.destroy_facility_gakudo_sonotagakudouhoiku_docs
    end
  end
end
