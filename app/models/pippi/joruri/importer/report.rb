module Pippi::Joruri::Importer
  class Report < Base
    attr_reader :groups, :users, :nodes, :categories, :csv, :upload_files_path

    def initialize(site)
      super(site)

      @groups = {}
      %w(認定NPO法人はままつ子育てネットワークぴっぴ).each do |name|
        @groups[name] = SS::Group.find_by(name: name)
      end

      @users = {}
      ["システム管理者", "ぴっぴ 村松", "ぴっぴ 仲子", "ぴっぴ 三輪", "ぴっぴ 森口", "ぴっぴ 時田祐子", "ぴっぴ 藤田"].each do |name|
        @users[name] = SS::User.find_by(name: name)
      end

      @nodes = {}
      ["浜松の子育て支援レポート", "クローズアップ「ひと」", "パパママインタビュー", "耳より情報", "子育て応援企業紹介"].each do |name|
        @nodes[name] = Article::Node::Page.site(@site).find_by(filename: /^blog\/report\//, name: name)
      end

      @categories = {}
      ["浜松の子育て支援レポート", "クローズアップ「ひと」", "パパママインタビュー", "耳より情報", "子育て応援企業紹介"].each do |name|
        @categories[name] = Category::Node::Base.site(@site).find_by(filename: /^blog\/report\//, name: name)
      end

      @upload_files_path = "joruri_files/1125/upload_files"
    end

    def import_report_docs
      @csv = CSV.open("import_report_docs_#{Time.zone.now.to_i}.csv",'w')
      @categories.each do |name, category|
        import_with_category(category)
      end
    end

    def import_with_category(category)
      path = ::File.join(csv_path, "report_#{category.basename}.csv")
      import_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      import_csv.each_with_index do |row, idx|
        next if row["id"].blank?

        original_id = row["id"]
        state = row["state"]
        created_at = Time.zone.parse(row["created_at"])
        updated_at = Time.zone.parse(row["updated_at"])
        published_at = Time.zone.parse(row["published_at"]) rescue nil
        name_id = row["name"]
        title = row["title"]
        body = row["body"]
        zokusei = row["属性"]
        group_name = row["グループ"]
        user_name = row["作成者"].to_s.strip
        original_url = row["URL"]
        files_paths = row["ファイルパス（内部）"].to_s.split(/\r?\n/)
        files_filenames = row["ファイル名（内部）"].to_s.split(/\r?\n/)
        files_names = row["ファイル表記（内部）"].to_s.split(/\r?\n/)

        node = nodes[category.name]
        layout = node.page_layout
        group = groups[group_name]
        user = users[user_name]

        raise "node not found!" if node.nil?
        raise "unknown group! #{group_name}" if group.nil?
        raise "unknown user! #{user_name}" if user.nil?

        rel_Joruri = Pippi::Joruri::Relation::Report.where(joruri_id: original_id).first
        if rel_Joruri
          item = rel_Joruri.owner_item
        else
          item = Article::Page.new
          rel_Joruri = Pippi::Joruri::Relation::Report.new
        end

        # save article
        item.cur_site = site
        item.cur_node = node
        item.cur_user = user
        item.layout = layout
        item.group_ids = [group.id]
        item.name = title
        item.created = created_at
        item.updated = updated_at
        if published_at
          item.released_type = "fixed"
          item.released = published_at
          item.first_released = published_at
        end
        item.state = (state == "draft") ? "closed" : "public"
        item.category_ids = [category.id]
        item.html = body

        puts "#{idx}.[#{category.name}] #{item.name}"
        def item.set_updated; end
        item.save!

        # save joruri relation
        rel_Joruri.owner_item = item
        rel_Joruri.joruri_id = original_id
        rel_Joruri.joruri_url = original_url
        rel_Joruri.joruri_updated = updated_at
        rel_Joruri.save!

        # save files
        save_html_and_files(item, user, item, files_paths, files_filenames, files_names)

        csv << [::File.join(site.full_url, item.private_show_path), item.full_url, category.name, rel_Joruri.joruri_url]
        csv.flush
      end
    end

    def ext_downcase(filename)
      basename, ext = filename.split(".")
      [basename, ext.to_s.downcase].join(".")
    end

    def save_html_and_files(item, user, embedder, files_paths, files_filenames, files_names)
      return if files_paths.blank?

      # format file extension
      files_filenames = files_filenames.map { |filename| ext_downcase(filename) }

      files = []
      files_paths.each_with_index do |path, idx|
        path = ::File.join(upload_files_path, ::File.basename(path))
        filename = files_filenames[idx]
        name = files_names[idx]
        puts "- #{filename}"

        ss_file = embedder.files.where(filename: filename).first
        if ss_file
          files << ss_file
          next
        end

        raise "not found joruri file!" if !::File.exists?(path)
        ss_file = SS::File.new
        ss_file.in_file = Fs::UploadedFile.create_from_file(path)
        ss_file.site = site
        ss_file.user = user
        ss_file.filename = filename
        ss_file.name = name
        ss_file.model = item.class.name
        ss_file.owner_item = item
        ss_file.save!
        ss_file.set(content_type: ::Fs.content_type(filename))
        files << ss_file
      end
      file_ids = files.map(&:id)

      # replace file paths
      files = files.index_by { |item| item.filename }
      html = embedder.instance_of?(Cms::Column::Value::Free) ? embedder.value.to_s : embedder.html.to_s
      html = html.gsub(/(href|src)="(.*?)"/) do |str|
        scheme = $1
        path = ::Addressable::URI.parse($2).path
        filename = ext_downcase(::File.basename(path))
        if path =~ /files\// && files[filename]
          "#{scheme}=\"#{files[filename].url}\""
        else
          str
        end
      end

      if embedder.instance_of?(Cms::Column::Value::Free)
        embedder.file_ids = file_ids
        embedder.value = html
      else
        embedder.file_ids = file_ids
        embedder.html = html
      end
      item.save!
    end

    def restore_links(html, dir, &block)
      html.to_s.gsub(/(href|src)="(.*?)"/) do |matched|
        protocol = $1
        uri = ::Addressable::URI.parse($2)

        if uri.host && uri.host != joruri_host
          # other site
          yield(uri.to_s, nil, "外部サイト")
          next matched
        end

        if uri.scheme == "mailto"
          # mail_to
          next matched
        end

        if uri.path =~ /^\/fs\//
          # shirasagi fs file
          next matched
        end

        if uri.path =~ /^\/_common\//
          # shirasagi upload file
          next matched
        end

        if uri.path.blank?
          # anchor link?
          next matched
        end

        url = ::File.join(joruri_base_url, Pathname(dir).join(uri.path))
        rel = Pippi::Joruri::Relation::Doc.where(joruri_url: url).first
        if !rel
          # not found relation
          yield(uri.to_s, nil, "置換対象が存在しない")
          next matched
        end

        yield(uri.to_s, rel.owner_item.url, "リンク置換")
        "#{protocol}=\"#{rel.owner_item.url}\""
      end
    end

    def restore_relations_report_docs
      csv = CSV.open("fix_relations_report_docs_#{Time.zone.now.to_i}.csv",'w')

      Pippi::Joruri::Relation::Report.each_with_index do |rel_Joruri, idx|
        item = rel_Joruri.owner_item
        dir = rel_Joruri.joruri_url.sub(joruri_base_url, "")
        puts "#{idx}.#{item.name}"

        html = item.html

        # generic links
        html = restore_links(html, dir) do |src, dist, action|
          csv << [::File.join(site.full_url, item.private_show_path), item.full_url, src, dist, action]
          csv.flush
        end

        item.html = html

        def item.set_updated; end
        item.save!
      end
    end

    def destroy_report_docs
      Pippi::Joruri::Relation::Report.each_with_index do |item, idx|
        puts "#{idx}.#{item.joruri_url}"
        item.owner_item.destroy if item.owner_item
        item.destroy
      end
    end
  end
end
