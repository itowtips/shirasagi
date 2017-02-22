namespace :site_appender do
  task :check_valid => :environment do
    puts "## check model validation"
    puts ""

    def check_valid(item)
      item = item.becomes_with_inner_id
      begin
        item.valid?
      rescue => e
        puts " #{e.class} #{item.class} #{item.id} #{item.name}"
        puts " #{e.backtrace.join("\n  ")}"
        puts ""
      end
    end

    puts "# SS::File"
    SiteAppender::Inner::SS::File.each_with_index do |item, idx|
      check_valid(item)
    end
    puts ""

    puts "# SS::Group"
    SiteAppender::Inner::SS::Group.each_with_index do |item, idx|
      check_valid(item)
    end
    puts ""

    puts "# SS::User"
    SiteAppender::Inner::SS::User.each_with_index do |item, idx|
      check_valid(item)
    end
    puts ""

    puts "# Cms::Role"
    SiteAppender::Inner::Cms::Role.each_with_index do |item, idx|
      check_valid(item)
    end
    puts ""

    puts "# Cms::Layout"
    SiteAppender::Inner::Cms::Layout.each_with_index do |item, idx|
      check_valid(item)
    end
    puts ""

    puts "# Cms::Part"
    SiteAppender::Inner::Cms::Part.each_with_index do |item, idx|
      check_valid(item)
    end
    puts ""

    puts "# Cms::Node"
    SiteAppender::Inner::Cms::Node.each_with_index do |item, idx|
      check_valid(item)
    end
    puts ""

    puts "# Cms::Page"
    SiteAppender::Inner::Cms::Page.each_with_index do |item, idx|
      check_valid(item)
    end
    puts ""

    puts "# Inquiry::Answer"
    SiteAppender::Inner::Inquiry::Answer.each_with_index do |item, idx|
      check_valid(item)
    end
    puts ""

    puts "# Inquiry::Column"
    SiteAppender::Inner::Inquiry::Column.each_with_index do |item, idx|
      check_valid(item)
    end
    puts ""

    puts "# History::Backup"
    SiteAppender::Inner::History::Backup.each_with_index do |item, idx|
      check_valid(item)
    end
    puts ""

    puts "# History::Log"
    SiteAppender::Inner::History::Log.each_with_index do |item, idx|
      check_valid(item)
    end
    puts ""
  end
end
