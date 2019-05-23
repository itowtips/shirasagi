namespace :debug do
  task restore_files: :environment do
    puts "restore files"
    file_ids = SS::File.all.pluck(:id)
    file_ids.each do |id|
      file = SS::File.find(id) rescue nil
      next if file.nil?
      next if ::File.exists?(file.path)

      path = "#{Rails.root}/spec/fixtures/debug/restore_file/#{file.extname}.#{file.extname}"
      if ::File.exists?(path) && !::File.directory?(path)
        Fs.binwrite file.path, File.binread(path)
        puts "restore : #{file.filename}"
      else
        puts "error : unknown format #{file.extname} (#{file.filename})"
      end
    end
  end
end
