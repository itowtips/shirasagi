namespace :ss do
  task restore_files_0307: :environment do
    f = ::File.open("article_ids.txt")
    f.each_line do |line|
      page = Cms::Page.find(line.to_i)
      state = page.state

      page.files.each do |file|
        if file.state != state
          p file.filename
        end
      end
    end
  end
end
