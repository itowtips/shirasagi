module Pippi::Joruri::Importer
  class Blog < Base
    attr_reader :groups, :users, :hint_nodes, :hint_categories, :bousai_node, :bousai_category

    def initialize(site)
      super(site)

      @groups = {}
      %w(認定NPO法人はままつ子育てネットワークぴっぴ).each do |name|
        @groups[name] = SS::Group.find_by(name: name)
      end

      @users = {}
      ["システム管理者", "ブログ担当", "ぴっぴ 森口", "ぴっぴ 仲子", "ぴっぴ 三輪", "ぴっぴ 村松", "ぴっぴ 藤田"].each do |name|
        @groups[name] = SS::User.find_by(name: name)
      end

      @hint_nodes = {}
      %w(からだと心 遊びや学び 妊娠・出産 執筆者紹介 食事とおやつ おすすめ図書 ライフスタイル).each do |name|
        @hint_nodes[name] = Article::Node::Page.site(@site).find_by(filename: /^blog\/hint\//, name: name)
      end

      @hint_categories = {}
      %w(からだと心 遊びや学び 妊娠・出産 執筆者紹介 食事とおやつ おすすめ図書 ライフスタイル).each do |name|
        @hint_categories[name] = Category::Node::Base.site(@site).find_by(filename: /^blog\/hint\//, name: name)
      end

      @bousai_node = Article::Node::Page.site(@site).find_by(filename: /^blog\/hint\//, name: "防災豆知識")
      @bousai_category =  Category::Node::Base.site(@site).find_by(filename: /^blog\/hint\//, name: "防災豆知識")
      @bousai_tags = {}
      ["忘れない3.11"].each do |name|
        @bousai_tags[name] = Category::Node::Base.site(@site).find_by(filename: /^blog\/hint\//, name: name)
      end
    end

    def import_hint_docs
      csv = CSV.open("import_hint_docs_#{Time.zone.now.to_i}.csv",'w')

      path = ::File.join(csv_path, "hint.csv")
      hint_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      hint_csv.each_with_index do |row, idx|
        next if row["id"].blank?

        original_id = row["id"]
        state = row["state"]
        created_at = Time.zone.parse(row["created_at"])
        updated_at = Time.zone.parse(row["updated_at"])
        published_at = Time.zone.parse(row["published_at"])
        name_id = row["name"]
        title = row["title"]
        body = row["body"]
        zokusei = row["属性"]
        group_name = row["グループ"]
        user_name = row["作成者"]
        original_url = row["URL"]
        category = row["新カテゴリ"]
        files_paths = row["ファイルパス（内部）"].to_s.split(/\r?\n/)
        files_filenames = row["ファイル名（内部）"].to_s.split(/\r?\n/)
        files_names = row["ファイル表記（内部）"].to_s.split(/\r?\n/)

        is_author = (category == "執筆者紹介")
        node = hint_nodes[category]
        layout = node.page_layout
        form = node.st_form_default
        category_node = hint_categories[category]
        group = groups[group_name]
        user = users[user_name]

        raise "unknown category! : #{category}" if node.nil? || category_node.nil?
        raise "unknown group! #{group_name}" if group.nil?

        rel_Joruri = Pippi::Joruri::Relation::Hint.where(joruri_id: original_id).first
        if rel_Joruri
          item = rel_Joruri.owner_item
        else
          item = Article::Page.new
          rel_Joruri = Pippi::Joruri::Relation::Hint.new
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
        item.released_type = "fixed"
        item.released = published_at
        item.first_released = published_at
        item.state = (state == "draft") ? "closed" : "public"
        item.category_ids = [category_node.id]

        if is_author
          item.html = body
        else
          # column values
          column_values = form.columns.map { |column| column.value_type.new(column: column) }
          column_values[0].value = body

          item.form = form
          item.column_values = column_values
        end

        puts "#{idx}.[#{category}] #{item.name}"
        def item.set_updated; end
        item.save!

        # save joruri relation
        rel_Joruri.owner_item = item
        rel_Joruri.joruri_id = original_id
        rel_Joruri.joruri_url = original_url
        rel_Joruri.joruri_updated = updated_at
        rel_Joruri.save!

        # save files
        if is_author
          save_html_and_files(item, user, item, files_paths, files_filenames, files_names)
        else
          save_html_and_files(item, user, item.column_values[0], files_paths, files_filenames, files_names)
        end

        csv << [::File.join(site.full_url, item.private_show_path), item.full_url, category, rel_Joruri.joruri_url]
        csv.flush
      end
    end

    def save_html_and_files(item, user, embedder, files_paths, files_filenames, files_names)
      return if files_paths.blank?

      files = []
      files_paths.each_with_index do |path, idx|
        path = "joruri_files/upload_files/#{::File.basename(path)}"
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
        files<< ss_file
      end
      file_ids = files.map(&:id)

      # replace file paths
      files = files.index_by { |item| item.filename }
      html = embedder.instance_of?(Cms::Column::Value::Free) ? embedder.value.to_s : embedder.html.to_s
      html = html.gsub(/(href|src)="(.*?)"/) do |str|
        scheme = $1
        path = $2
        if path =~ /files\// && files[::File.basename(path)]
          "#{scheme}=\"#{files[::File.basename(path)].url}\""
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

        if uri.path =~ /^\/fs\//
          # shirasagi fs file
          next matched
        end

        if uri.path =~ /^\/_common\/themes\//
          # shirasagi upload file
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

    def restore_relations_hint_docs
      csv = CSV.open("fix_relations_hint_docs_#{Time.zone.now.to_i}.csv",'w')

      Pippi::Joruri::Relation::Hint.each_with_index do |rel_Joruri, idx|
        item = rel_Joruri.owner_item
        dir = rel_Joruri.joruri_url.sub(joruri_base_url, "")
        is_author = item.categories.map(&:name).include?("執筆者紹介")
        puts "#{idx}.#{item.name}"

        html = is_author ? item.html : item.column_values[0].value

        # generic links
        html = restore_links(html, dir) do |src, dist, action|
          csv << [::File.join(site.full_url, item.private_show_path), item.full_url, src, dist, action]
          csv.flush
        end

        if is_author
          item.html = html
        else
          item.column_values[0].value = html
        end

        def item.set_updated; end
        item.save!
      end
    end

    def destroy_hint_docs
      Pippi::Joruri::Relation::Hint.each_with_index do |item, idx|
        puts "#{idx}.#{item.joruri_url}"
        item.owner_item.destroy if item.owner_item
        item.destroy
      end
    end

    def import_bousai_docs
      csv = CSV.open("import_bousai_docs_#{Time.zone.now.to_i}.csv",'w')

      path = ::File.join(csv_path, "bousai.csv")
      hint_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      hint_csv.each_with_index do |row, idx|
        next if row["id"].blank?

        original_id = row["id"]
        state = row["state"]
        created_at = Time.zone.parse(row["created_at"])
        updated_at = Time.zone.parse(row["updated_at"])
        published_at = Time.zone.parse(row["published_at"])
        name_id = row["name"]
        title = row["title"]
        body = row["body"]
        zokusei = row["属性"]
        group_name = row["グループ"]
        user_name = row["作成者"]
        original_url = row["URL"]
        files_paths = row["ファイルパス（内部）"].to_s.split(/\r?\n/)
        files_filenames = row["ファイル名（内部）"].to_s.split(/\r?\n/)
        files_names = row["ファイル表記（内部）"].to_s.split(/\r?\n/)

        node = bousai_node
        layout = node.page_layout
        form = node.st_form_default
        category_node = bousai_category
        group = groups[group_name]
        user = users[user_name]

        raise "unknown group! #{group_name}" if group.nil?

        rel_Joruri = Pippi::Joruri::Relation::Bousai.where(joruri_id: original_id).first
        if rel_Joruri
          item = rel_Joruri.owner_item
        else
          item = Article::Page.new
          rel_Joruri = Pippi::Joruri::Relation::Bousai.new
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
        item.released_type = "fixed"
        item.released = published_at
        item.first_released = published_at
        item.state = (state == "draft") ? "closed" : "public"
        item.category_ids = [category_node.id]

        if zokusei == "忘れない3.11"
          item.category_ids = item.category_ids.to_a + [@bousai_tags["忘れない3.11"].id]
        end

        column_values = form.columns.map { |column| column.value_type.new(column: column) }
        column_values[0].value = body

        item.form = form
        item.column_values = column_values

        puts "#{idx}.[#{category_node.name}] #{item.name}"
        def item.set_updated; end
        item.save!

        # save joruri relation
        rel_Joruri.owner_item = item
        rel_Joruri.joruri_id = original_id
        rel_Joruri.joruri_url = original_url
        rel_Joruri.joruri_updated = updated_at
        rel_Joruri.save!

        # save files
        save_html_and_files(item, user, item.column_values[0], files_paths, files_filenames, files_names)

        csv << [::File.join(site.full_url, item.private_show_path), item.full_url, category_node.name, rel_Joruri.joruri_url]
        csv.flush
      end
    end

    def restore_relations_bousai_docs
      csv = CSV.open("fix_relations_bousai_docs_#{Time.zone.now.to_i}.csv",'w')

      Pippi::Joruri::Relation::Bousai.each_with_index do |rel_Joruri, idx|
        item = rel_Joruri.owner_item
        dir = rel_Joruri.joruri_url.sub(joruri_base_url, "")
        html = item.column_values[0].value
        puts "#{idx}.#{item.name}"

        # generic links
        html = restore_links(html, dir) do |src, dist, action|
          csv << [::File.join(site.full_url, item.private_show_path), item.full_url, src, dist, action]
          csv.flush
        end

        item.column_values[0].value = html
        def item.set_updated; end
        item.save!
      end
    end

    def destroy_bousai_docs
      Pippi::Joruri::Relation::Bousai.each_with_index do |item, idx|
        puts "#{idx}.#{item.joruri_url}"
        item.owner_item.destroy if item.owner_item
        item.destroy
      end
    end
  end
end
