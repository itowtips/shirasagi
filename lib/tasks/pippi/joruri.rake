namespace :pippi do
  namespace :joruri do
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

=begin
  task hint2: :environment do
    hint2 = {}
    path = ::File.join(Rails.root, "lib/tasks/pippi/blog/hint2.csv")
    csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
    csv.each_with_index do |row, idx|
      id = row["id"].to_i
      files_names = row["ファイル表記（内部）"]
      hint2[id] = [files_names]
    end

    path = ::File.join(Rails.root, "lib/tasks/pippi/blog/hint.csv")
    csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
    CSV.open('hint3.csv','w') do |f|
      f << csv.headers
      csv.each_with_index do |row, idx|
        fields = csv.headers.map { |head| row[head] }
        id = row["id"].to_i
        f << (fields + hint2[id])
      end
    end
  end
=end
  end
end
