namespace :mail_page do
  task :import_mail => :environment do
    puts "Please input site_name: site=[site_name]" or exit if ENV['site'].blank?

    site = Cms::Site.where(host: ENV['site']).first
    puts "Site not found: #{ENV['site']}" or exit unless site

    data = STDIN.read
    job = MailPage::ImportJob.bind(site_id: site.id)
    job.perform_now(data)
  end
end
