class Gws::Memo::ExportMessageJob < Gws::ApplicationJob

  def perform(opts = {})
    message_ids = opts[:message_ids]
    return if message_ids.blank?

    @datetime = Time.zone.now
    @messages = Gws::Memo::Message.site(site).in(message_ids: message_ids)
    @output_zip = SS::DownloadJobFile.new(user, "gws-memo-messages-#{@datetime.strftime('%Y%m%d%H%M%S')}.zip")
    @output_dir = @output_zip.path.sub(::File.extname(@output_zip.path), "")
    @ss_file_ids = []
    @gws_user_ids = []

    FileUtils.rm_rf(@output_dir)
    FileUtils.rm_rf(@output_zip.path)
    FileUtils.mkdir_p(@output_dir)

    export_version
    export_gws_memo_messages
    export_gws_users
    export_ss_files
    compress

    FileUtils.rm_rf(@output_dir)

    create_notify_message
  end

  def export_version
    write_json "version", SS.version.to_json
  end

  def export_gws_memo_messages
    json = open_json("gws_memo_messages")
    @messages.pluck(:id).each do |id|
      item = Gws::Memo::Message.unscoped.find(id)
      json.write(item.to_json)

      # store file ids
      @ss_file_ids += item[:file_ids] if item[:file_ids].present?
      @ss_file_ids << item[:thumb_id] if item[:thumb_id].present?

      # store user ids
      @gws_user_ids << item[:user_id] if item[:user_id].present?
      @gws_user_ids += item[:member_ids] if item[:member_ids].present?
      @gws_user_ids += item[:to_member_ids] if item[:to_member_ids].present?
      @gws_user_ids += item[:cc_member_ids] if item[:cc_member_ids].present?
      @gws_user_ids += item[:bcc_member_ids] if item[:bcc_member_ids].present?
      @gws_user_ids.uniq!
    end
    json.close
  end

  def export_ss_files
    FileUtils.mkdir_p("#{@output_dir}/files")

    json = open_json("ss_files")
    @ss_file_ids.compact.sort.each do |id|
      item = SS::File.unscoped.find(id) rescue nil
      next unless item

      item[:export_path] = copy_file(item)
      json.write(item.to_json)

      item.thumbs.each do |thumb|
        thumb[:export_path] = copy_file(thumb)
        json.write(thumb.to_json)
      end
    end
    json.close
  end

  def export_gws_users
    json = open_json("cms_users")
    @gws_user_ids.each do |id|
      item = Gws::User.unscoped.find(id)
      json.write(item.to_json)
    end
    json.close
  end

  def compress
    FileUtils.rm(@output_zip.path) if File.exist?(@output_zip.path)
    Zip::File.open(@output_zip.path, Zip::File::CREATE) do |zip|
      add_json(zip)
      add_private_files(zip)
    end
  end

  def create_notify_message
    item = Gws::Memo::Message.new
    item.cur_site = site
    item.cur_user = user
    item.to_member_ids = [user.id]
    item.subject = I18n.t("gws/memo/message.export.subject", datetime: @datetime.strftime('%Y/%m/%d %H:%M'))
    item.format = "text"
    item.text = I18n.t("gws/memo/message.export.notiry_message", link: @output_zip.url)
    item.send_date = @datetime
    item.deleted = { "sent" => @datetime }
    item.save!
  end

  def copy_file(item)
    return nil unless File.exist?(item.path)
    file = item.path.sub(/.*\/(files\/)/, '\\1')
    path = "#{@output_dir}/#{file}"
    FileUtils.mkdir_p(File.dirname(path))
    FileUtils.cp(item.path, path)
    file
  end

  def open_json(name)
    Sys::SiteExport::Json.new("#{@output_dir}/#{name}.json")
  end

  def write_json(name, data)
    File.write("#{@output_dir}/#{name}.json", data)
  end

  def add_json(zip)
    Dir.glob("#{@output_dir}/*.json").each do |file|
      name = ::File.basename(file)
      zip.add(name, file)
    end
  end

  def add_private_files(zip)
    require "find"
    Find.find("#{@output_dir}/files") do |path|
      entry = path.sub(/.*\/(files\/?)/, '\\1')
      if File.directory?(path)
        zip.mkdir(entry)
      else
        zip.add(entry, path)
      end
    end
  end
end
