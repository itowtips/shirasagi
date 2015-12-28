namespace :facility do
  task :sync_institutions => :environment do
    site = Cms::Site.first
    url = "http://27.120.83.11/medinet3-upd-release/cron/cron_shirasagi_institution.php"
    Facility::SyncInstitutionsJob.call_async(site.host, url) do |job|
      job.site_id = site.id
      job.user_id = nil
    end

    Rake::Task["job:run"].invoke
  end
end
