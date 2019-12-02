module Translate::Page
  extend ActiveSupport::Concern
  extend SS::Translation

  def remove_translated_files
    files = Fs.glob(::File.join(site.path, "translate/#{target}", filename))
    files.each do |path|
      Fs.rm_rf(path)
    end
  end

  def rename_translated_files
    site.translate_targets.each do |target|
      src = "#{site.translate_path(target)}/#{@db_changes['filename'][0]}"
      dst = "#{site.translate_path(target)}/#{@db_changes['filename'][1]}"
      dst_dir = ::File.dirname(dst)

      Fs.mkdir_p dst_dir unless Fs.exists?(dst_dir)
      Fs.mv src, dst if Fs.exists?(src)
    end
  end

  def generate_translate_files
    return false unless serve_static_file?
    return false unless public?
    return false unless public_node?
    Translate::Agents::Tasks::PagesController.new.generate_translate_page(self)
  end
end
