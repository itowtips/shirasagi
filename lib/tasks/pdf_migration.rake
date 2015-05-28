namespace :ss do
  task :pdf_content_type_migration => :environment  do
    SS::File.each do |file|
      next unless ::File.extname(file.filename) == ".pdf"
      ct = ::SS::MimeType.find(file.filename, file.content_type)
      if ct != file.content_type
        file.update! content_type: ct
        puts file.name
      end
    end
  end
end

