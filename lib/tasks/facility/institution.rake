namespace :facility do
  task :sync_institutions => :environment do
    site = ENV["site"]
    url = ENV["url"]
    Facility::SyncInstitutionsJob.call_async(site, url)
    Rake::Task["job:run"].invoke
  end
end
