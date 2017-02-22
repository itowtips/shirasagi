namespace :site_appender do
  task :fix_relations => :environment do
    puts "Please input inner_site_name: inner=[inner_site_name]" or exit if ENV['inner'].blank?
    @site = SS::Site.where(host: ENV['inner']).first

    puts "## fix relations"
    puts ""

    puts "# SS::File"
    SiteAppender::Inner::SS::File.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.fix_inner_relations

      begin
        item.fix_thumb_original_id
      rescue => e
        puts "#{e.class} #{item.class} original_id"
      end
    end
    puts ""

    puts "# SS::Group"
    SiteAppender::Inner::SS::Group.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.fix_inner_relations
    end
    puts ""

    puts "# SS::User"
    SiteAppender::Inner::SS::User.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.fix_inner_relations
    end
    puts ""

    puts "# Cms::Role"
    SiteAppender::Inner::Cms::Role.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.fix_inner_relations
    end
    puts ""

    puts "# Cms::Layout"
    SiteAppender::Inner::Cms::Layout.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.fix_inner_relations
    end
    puts ""

    puts "# Cms::Part"
    SiteAppender::Inner::Cms::Part.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.fix_inner_relations
    end
    puts ""

    puts "# Cms::Node"
    SiteAppender::Inner::Cms::Node.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.fix_inner_relations
    end
    puts ""

    puts "# Cms::Page"
    SiteAppender::Inner::Cms::Page.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.fix_inner_relations

      begin
        item.fix_workflow_approvers
      rescue => e
        puts "#{e.class} #{item.class} workflow_approvers"
      end
    end
    puts ""

    puts "# Inquiry::Answer"
    SiteAppender::Inner::Inquiry::Answer.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.fix_inner_relations
    end
    puts ""

    puts "# Inquiry::Column"
    SiteAppender::Inner::Inquiry::Column.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.fix_inner_relations
    end
    puts ""

    puts "# History::Backup"
    SiteAppender::Inner::History::Backup.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.fix_inner_relations

      begin
        item.fix_data_hash_id(@site)
      rescue => e
        puts "#{e.class} #{item.class} data.id"
      end
    end
    puts ""

    puts "# History::Log"
    SiteAppender::Inner::History::Log.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.fix_inner_relations
    end
    puts ""
  end
end
