namespace :translate do
  task generate_nodes: :environment do
    ::Tasks::Translate.generate_nodes
  end

  task generate_pages: :environment do
    ::Tasks::Translate.generate_pages
  end
end
