namespace :site_appender do
  task :append_documents => :environment do
    puts "Please input inner_site_name: inner=[inner_site_name]" or exit if ENV['inner'].blank?
    puts "Please input outer_path: private_path=[outer_path]" or exit if ENV['outer_path'].blank?

    @site = SS::Site.where(host: ENV['inner']).first
    @outer_path = ENV['outer_path']
    SiteAppender::Outer::SS::File.root = ::File.join("/", @outer_path, "private/files")

    puts "## save outer documents"
    puts ""

    puts "# SS::File"

    puts " destory old inner documents"
    SiteAppender::Inner::SS::File.destroy_all
    SiteAppender::Outer::SS::File.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.save_inner(@site)
    end
    puts ""

    puts "# SS::Group"

    puts " destory old inner documents"
    SiteAppender::Inner::SS::Group.destroy_all
    SiteAppender::Outer::SS::Group.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.save_inner(@site)
    end
    puts ""

    puts "# SS::User"

    puts " destory old inner documents"
    SiteAppender::Inner::SS::User.destroy_all
    SiteAppender::Outer::SS::User.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.save_inner(@site)
    end
    puts ""

    puts "# Cms::Layout"

    puts " destory old inner documents"
    SiteAppender::Inner::Cms::Layout.destroy_all
    SiteAppender::Outer::Cms::Layout.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.save_inner(@site)
    end
    puts ""

    puts "# Cms::Part"

    puts " destory old inner documents"
    SiteAppender::Inner::Cms::Part.destroy_all
    SiteAppender::Outer::Cms::Part.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.save_inner(@site)
    end
    puts ""

    puts "# Cms::Page"

    puts " destory old inner documents"
    SiteAppender::Inner::Cms::Page.destroy_all
    SiteAppender::Outer::Cms::Page.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.save_inner(@site)
    end
    puts ""

    puts "# Cms::Node"

    puts " destory old inner documents"
    SiteAppender::Inner::Cms::Node.destroy_all
    SiteAppender::Outer::Cms::Node.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.save_inner(@site)
    end
    puts ""

    puts "# Cms::Role"

    puts " destory old inner documents"
    SiteAppender::Inner::Cms::Role.destroy_all
    SiteAppender::Outer::Cms::Role.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.save_inner(@site)
    end
    puts ""

    puts "# Inquiry::Answer"

    puts " destory old inner documents"
    SiteAppender::Inner::Inquiry::Answer.destroy_all
    SiteAppender::Outer::Inquiry::Answer.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.save_inner(@site)
    end
    puts ""

    puts "# Inquiry::Column"

    puts " destory old inner documents"
    SiteAppender::Inner::Inquiry::Column.destroy_all
    SiteAppender::Outer::Inquiry::Column.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.save_inner(@site)
    end
    puts ""

    puts "# History::Backup"

    puts " destory old inner documents"
    SiteAppender::Inner::History::Backup.destroy_all
    SiteAppender::Outer::History::Backup.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.save_inner(@site)
    end
    puts ""

    puts "# History::Log"

    puts " destory old inner documents"
    SiteAppender::Inner::History::Log.destroy_all
    SiteAppender::Outer::History::Log.each_with_index do |item, idx|
      puts "#{idx} #{item.name}"
      item.save_inner(@site)
    end
    puts ""
  end
end
