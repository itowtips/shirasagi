namespace :recommend do
  def find_sites(site)
    return Cms::Site unless site
    Cms::Site.where host: site
  end

  def with_site(job_class, opts = {})
    find_sites(ENV["site"]).each do |site|
      job = job_class.bind(site_id: site)
      job.perform_now(opts)
    end
  end

  task :create_matrix => :environment do
    Recommend::CreateMatrixJob.bind(days: ENV["site"]).perform_now
  end

  task :create_random_logs => :environment do
    with_site(Recommend::CreateRandomLogJob)
  end
end
