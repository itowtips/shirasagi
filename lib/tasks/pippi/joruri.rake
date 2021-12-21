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
  end
end
