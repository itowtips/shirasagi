class Gws::Memo::MessageImporter
  include ActiveModel::Model
  include Sys::SiteImport::File

  attr_accessor :cur_site, :cur_user, :in_file

  def import_messages
    @datetime = Time.zone.now
    @import_dir = "#{Rails.root}/private/import/gws-memo-messages-#{Time.zone.now.to_i}"
    @ss_files_map = {}
    @gws_users_map = {}


    FileUtils.rm_rf(@import_dir)
    FileUtils.mkdir_p(@import_dir)

    Zip::File.open(in_file.path) do |entries|
      entries.each do |entry|
        path = "#{@import_dir}/" + entry.name.encode("UTF-8").tr('\\', '/')

        if entry.directory?
          FileUtils.mkdir_p(path)
        else
          File.binwrite(path, entry.get_input_stream.read)
        end
      end
    end

    init_gws_users_map

    #import_ss_files
    #import_documents "gws_memo_messages", Gws::Memo::Message
    #update_ss_files
  end

  def init_gws_users_map
    read_json("gws_users").each do |data|
      _id = data['_id']
      name = data['name']

      user = Gws::User.unscoped.find(_id) rescue nil
      if user && user.name == name
        @gws_users_map[_id.to_i] = user
      end
    end
  end

  def import_gws_memo_messages
    read_json("gws_memo_messages").each do |data|
      data.delete('_id')
      data.each { |k, v| item[k] = v }

      item = Gws::Memo::Message.new
      item.site_id = cur_site.id
      item.filtered = { cur_user.id => @datetime }
      item.member_ids = [user.id]




      if item.save
        map[id] = item.id
      end
    end
  end

  def read_json(name)
    path = "#{@import_dir}/#{name}.json"
    return [] unless File.file?(path)
    file = File.read(path)
    JSON.parse(file)
  end

  def convert_data(data)
    data
  end
end
