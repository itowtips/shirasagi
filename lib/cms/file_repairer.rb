class Cms::FileRepairer
  UTF8_BOM = "\uFEFF".freeze

  attr_reader :site, :csv, :csv_path, :timestamp

  private

  def set_site(site)
    @site = site
  end

  def set_csv_path(action)
    path = ::File.join(self.class.output_path, "#{action}_#{timestamp}")
    @csv_path = ::File.join(path, "#{site.name}.csv")
  end

  def csv_open
    Fs.rm_rf(csv_path) if ::File.exists?(csv_path)
    Fs.mkdir_p(::File.dirname(csv_path))
    file = ::File.open(csv_path, "w")
    file.print UTF8_BOM
    file.close
    @csv = CSV.open(csv_path, "a")
  end

  def emtpy_file?(file)
    return true if !::File.exists?(file.path)
    return true if ::File.binread(file.path, 20).blank?
    false
  end

  def same_file?(lf, rf)
    return false if emtpy_file?(lf)
    return false if emtpy_file?(rf)
    return false if lf.name != rf.name
    return false if lf.filename != rf.filename
    return false if !::FileUtils.cmp(lf.path, rf.path)
    true
  end

  def each_targets
    ids = Cms::Page.site(site).pluck(:id)
    ids.each_with_index do |id, idx|
      item = Cms::Page.find(id) rescue nil
      next unless item
      item = item.becomes_with_route
      puts "#{site.name} #{idx + 1}/#{ids.size}: #{item.name}"

      if item.respond_to?(:form) && item.form
        values = item.column_values
        values = values.to_a.select { |v| v._type == "Cms::Column::Value::Free" }
        values.each do |value|
          yield(item, value, value.value)
        end
      elsif item.respond_to?(:html)
        yield(item, item, item.html)
      end
    end
  end

  def each_files(html)
    file_urls = html.scan(/\"\/fs\/(.+?)\/_\//).flatten
    file_urls.each do |file_url|
      file_id = file_url.delete("/").to_i
      file = SS::File.find(file_id) rescue nil
      yield(file_id, file, file_url)
    end
  end

  def check_state(item, target, html)
    private_full_url = ::File.join(site.mypage_full_url, item.private_show_path)
    each_files(html) do |file_id, file, file_url|
      error_status = []

      if file
        if !target.file_ids.include?(file.id)
          error_status << "file_ids から外れている"
        end
        if file.owner_item_type.present?
          if file.owner_item.nil?
            error_status << "owner_item が設定されていない"
          end
          if file.owner_item && file.owner_item.id != item.id
            error_status << "owner_item が別ページを参照している (#{file.owner_item.id})"
          end
        else
          error_status << "owner_item_type が正常に設定されていない"
        end
        if file.site.nil?
          error_status << "site が設定されていない"
        end
        if item.state == "public" && file.state == "closed"
          error_status << "ページが公開状態だが、ファイルは非公開状態"
        end
        if item.state == "closed" && file.state == "public"
          error_status << "ページが非公開状態だが、ファイルは公開状態"
        end
        if emtpy_file?(file)
          error_status << "privateファイルが空"
        end
      else
        error_status << "ファイル自体が存在しない"
      end
      next if error_status.blank?

      csv.puts [
        item.id,
        item.name,
        item.label(:state),
        item.full_url,
        private_full_url,
        file_id,
        (file ? file.full_url : ""),
        error_status.join("\n")]
    end
  end

  def fix_state(item, target, html)
    private_full_url = ::File.join(site.mypage_full_url, item.private_show_path)
    each_files(html) do |file_id, file, file_url|
      next if file.nil?
      # ファイルが存在しなければ、修復不可
      restore_status = []

      if file.owner_item_type.present?
        if file.owner_item
          # owner_item が存在する
          if file.owner_item_id == item.id
            # owner_item がこのページを参照している
            if target.file_ids.include?(file.id)
              # file_ids にファイルが含まれている
              # 正常
            else
              # file_ids にファイルが含まれていない
              # file_ids に含めて修正する
              target.add_to_set(file_ids: file.id)
              restore_status << "ファイルIDを file_ids に含めて修復"
            end
          else
            # owner_item がこのページを参照していない
            # 修復不可
          end
        else
          # owner_item が存在しない
          # ファイルを、このページの所有ファイルとして修復する
          file.set(owner_item_id: item.id)
          fix_file_state(item, file)
          target.add_to_set(file_ids: file.id)
          restore_status << "ファイルをページの owner_item として修復"
        end
      else
        # owner_item が正しく設定できていない
        # 修復不可
      end

      if (item.state == "public" && file.state == "closed") ||
        (item.state == "closed" && file.state == "public") ||
        (item.site_id != file.site_id)
        fix_file_state(item, file)
        restore_status << "ファイルの state, site を修復"
      end
      next if restore_status.blank?

      csv.puts [
        item.id,
        item.name,
        item.label(:state),
        item.full_url,
        private_full_url,
        file_id,
        file.full_url,
        restore_status.join("\n")]
    end
  end

  def check_duplicate(item, target, html)
    delete_duplicate(item, target, html, false)
  end

  def delete_duplicate(item, target, html, delete = true)
    file_urls = html.scan(/\"(\/fs\/.+?)\"/).flatten
    private_full_url = ::File.join(site.mypage_full_url, item.private_show_path)

    delete_files = {}
    target.files.each do |lf|
      next if delete_files[lf.id]

      target.files.each do |rf|
        next if lf.id == rf.id
        next if delete_files[rf.id]
        next if file_urls.include?(rf.url)
        next if !same_file?(lf, rf)
        delete_files[rf.id] = [rf, lf.id]
      end
    end
    delete_files.values.each do |file, ref|
      csv.puts [
        item.id,
        item.name,
        item.label(:state),
        item.full_url,
        private_full_url,
        file.id,
        file.full_url,
        ref]
      file.destroy if delete
    end
  end

  def fix_file_state(item, file)
    state = item.state
    site_id = item.site_id
    thumb = nil

    file.set(state: state, site_id: site_id)
    if file.image?
      thumb = file.thumb
      if thumb && thumb.respond_to?(:state)
        thumb.set(state: state, site_id: site_id)
      end
    end

    if state == "closed"
      Fs.rm_rf(file.public_path) if ::File.exists?(file.public_path)
      if thumb && thumb.respond_to?(:public_path)
        Fs.rm_rf(thumb.public_path) if ::File.exists?(thumb.public_path)
      end
    end
  end

  public

  def initialize
    @timestamp = Time.zone.now.strftime("%Y%m%d_%H%M_%3N")
  end

  def check_states(site)
    set_site(site)
    set_csv_path("check_states")
    csv_open
    csv.puts %w(ID タイトル ステータス 公開画面 管理画面 ファイルID ファイルURL エラー)
    each_targets do |item, target, html|
      next if html.blank?
      next if !target.respond_to?(:file_ids)
      check_state(item, target, html)
    end
    csv.close
    puts "output: #{csv_path}"
  end

  def fix_states(site)
    set_site(site)
    set_csv_path("fix_states")
    csv_open
    csv.puts %w(ID タイトル ステータス 公開画面 管理画面 ファイルID ファイルURL 修復)
    each_targets do |item, target, html|
      next if html.blank?
      next if !target.respond_to?(:file_ids)
      fix_state(item, target, html)
    end
    csv.close
    puts "output: #{csv_path}"
  end

  def check_duplicates(site)
    set_site(site)
    set_csv_path("check_duplicates")
    csv_open
    csv.puts %w(ID タイトル ステータス 公開画面 管理画面 ファイルID ファイルURL 重複元)
    each_targets do |item, target, html|
      next if html.blank?
      next if !target.respond_to?(:file_ids)
      check_duplicate(item, target, html)
    end
    csv.close
    puts "output: #{csv_path}"
  end

  def delete_duplicates(site)
    set_site(site)
    set_csv_path("delete_duplicates")
    csv_open
    csv.puts %w(ID タイトル ステータス 公開画面 管理画面 ファイルID ファイルURL 重複元)
    each_targets do |item, target, html|
      next if html.blank?
      next if !target.respond_to?(:file_ids)
      delete_duplicate(item, target, html)
    end
    csv.close
    puts "output: #{csv_path}"
  end

  class << self
    def output_path
      ::File.join(Rails.root.to_s, "private/file_repair")
    end

    def clean
      if ::File.exists?(output_path)
        puts "remove: #{output_path}"
        Fs.rm_rf(output_path)
      end
    end
  end
end
