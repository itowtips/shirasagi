namespace :gws do
  namespace :portal do
    task sync_portal: :environment do
      ::Tasks::Gws::Portal.sync
    end

    task reset_portal: :environment do
      ::Tasks::Gws::Portal.reset
    end
  end
end
