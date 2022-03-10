namespace :cms do
  namespace :file_repair do
    task check_states: :environment do
      repairer = Cms::FileRepairer.new
      ::Tasks::Cms.each_sites do |site|
        puts "\# #{site.name}"
        repairer.check_states(site)
      end
    end

    task fix_states: :environment do
      repairer = Cms::FileRepairer.new
      ::Tasks::Cms.each_sites do |site|
        puts "\# #{site.name}"
        repairer.fix_states(site)
      end
    end

    task check_duplicates: :environment do
      repairer = Cms::FileRepairer.new
      ::Tasks::Cms.each_sites do |site|
        puts "\# #{site.name}"
        repairer.check_duplicates(site)
      end
    end

    task delete_duplicates: :environment do
      repairer = Cms::FileRepairer.new
      ::Tasks::Cms.each_sites do |site|
        puts "\# #{site.name}"
        repairer.delete_duplicates(site)
      end
    end

    task clean: :environment do
      Cms::FileRepairer.clean
    end
  end
end
