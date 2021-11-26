namespace :pippi do
  namespace :hamasuku do
    task import_users: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Hamasuku::Importer::User.new(site)
      importer.import_users
    end

    task import_categories: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Hamasuku::Importer::Node.new(site)
      importer.import_categories
    end

    task import_faq_pages: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Hamasuku::Importer::Page.new(site)
      importer.import_faq_pages
    end

    task restore_relations_faq_pages: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Hamasuku::Importer::Page.new(site)
      importer.restore_relations_faq_pages
    end

    task destroy_faq_pages: :environment do
      puts "Please input site: site=[www]" or exit if ENV['site'].blank?
      site = ::Cms::Site.where(host: ENV['site']).first
      importer = Pippi::Hamasuku::Importer::Page.new(site)
      importer.destroy_faq_pages
    end
  end
end
