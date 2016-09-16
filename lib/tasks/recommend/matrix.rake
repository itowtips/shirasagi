namespace :recommend do
  task :create_matrix => :environment do
    Recommend::CreateMatrixJob.bind(days: ENV["site"]).perform_now
  end
end
