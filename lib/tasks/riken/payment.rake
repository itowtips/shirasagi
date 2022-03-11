namespace :riken do
  namespace :payment do
    task import_workflows: :environment do
      ::Tasks::Riken::Payment.import_workflows
    end
  end
end
