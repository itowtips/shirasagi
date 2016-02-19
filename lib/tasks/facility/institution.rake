namespace :facility do
  task :sync_institutions => :environment do
    site = ENV["site"]
    urls = ENV["urls"].split(',')

    cur_site = Cms::Site.find_by(host: site)
    Facility::SyncInstitutionsJob.call_async(site, urls) do |job|
      job.site_id = cur_site.id
    end
    Rake::Task["job:run"].invoke
  end
end
