module Pippi::Joruri::Importer
  class Odekake < Base
    attr_reader :groups, :users, :author_node, :odekake_nodes, :odekake_categories, :odekake_areas, :author_category, :author_type_categories, :author_category_layout

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

      @author_node = Article::Node::Page.site(@site).find_by(filename: /^blog\/odekake\//, name: "取材者")

      @odekake_nodes = {}
      %w(レジャー・学習施設 飲食・買い物・サービス 季節のおすすめ情報 公園 イベント・講座・習い事 子育て支援・児童館 このブログについて).each do |name|
        @odekake_nodes[name] = Article::Node::Page.site(@site).find_by(filename: /^blog\/odekake\//, name: name)
      end

      @odekake_categories = {}
      %w(レジャー・学習施設 飲食・買い物・サービス 季節のおすすめ情報 公園 イベント・講座・習い事 子育て支援・児童館 このブログについて).each do |name|
        @odekake_categories[name] = Category::Node::Base.site(@site).find_by(filename: /^blog\/odekake\/category\//, name: name)
      end

      @odekake_areas = {}
      %w(中区 東区 西区 南区 北区 浜北区 天竜区 市外 その他).each do |name|
        @odekake_areas[name] = Category::Node::Base.site(@site).find_by(filename: /^blog\/odekake\/chiiki\//, name: name)
      end

      @author_category = Category::Node::Base.site(@site).find_by(filename: "blog/odekake/author-category")
      @author_type_categories = {}
      %w(OB 2021メンバー).each do |name|
        @author_type_categories[name] = Category::Node::Base.site(@site).find_by(filename: /^blog\/odekake\/author-category\//, name: name)
      end

      @author_category_layout = Cms::Layout.site(@site).find_by(name: "ぴっぴのブログ ＞ ページリスト用")
    end

    def import_odekake_authors
      csv = CSV.open("import_authors_#{Time.zone.now.to_i}.csv",'w')

      path = ::File.join(csv_path, "odekake/author.csv")
      hint_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      hint_csv.each_with_index do |row, idx|
        title = row["title"]
        body = row["body"]
        type = row["区分"]

        node = author_node
        layout = node.page_layout
        form = node.st_form_default
        group = groups["認定NPO法人はままつ子育てネットワークぴっぴ"]
        user = users["システム管理者"]

        # save article
        rel_Joruri = Pippi::Joruri::Relation::OdekakeAuthor.where(joruri_id: idx).first
        if rel_Joruri
          item = rel_Joruri.owner_item
        else
          item = Article::Page.new
          rel_Joruri = Pippi::Joruri::Relation::OdekakeAuthor.new
        end
        item.cur_site = site
        item.cur_node = node
        item.cur_user = user
        item.layout = layout
        item.group_ids = [group.id]
        item.name = title
        item.state = "public"

        column_values = form.columns.order_by(order: 1).map { |column| column.value_type.new(column: column) }
        column_values[1].value = body
        column_values[2].value = type

        item.form = form
        item.column_values = column_values

        puts "#{idx}.[#{node.name}][#{type}] #{item.name}"
        item.save!

        # save joruri relation
        rel_Joruri.owner_item = item
        rel_Joruri.joruri_id = idx
        rel_Joruri.save!

        csv << [::File.join(site.full_url, item.private_show_path), item.full_url, rel_Joruri.joruri_url]
        csv.flush
      end
    end

    def import_odekake_author_categories
      node = author_category
      layout = author_category_layout

      pages = {}
      Pippi::Joruri::Relation::Odekake.each do |rel|
        page = rel.owner_item
        title = page.column_values[3].value
        pages[title] ||= []
        pages[title] << page
      end

      path = ::File.join(csv_path, "odekake/author.csv")
      hint_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      hint_csv.each_with_index do |row, idx|
        group = groups["認定NPO法人はままつ子育てネットワークぴっぴ"]
        user = users["システム管理者"]
        title = row["title"]
        basename = row["ページ名"]
        node = author_type_categories[row["区分"]]
        filename = ::File.join(node.filename, basename)

        item = Category::Node::Page.site(site).where(filename: filename).first
        item = Category::Node::Page.new if item.nil?

        item.site = site
        item.user = user
        item.group_ids = [group.id]
        item.layout = layout
        item.name = title
        item.filename = filename
        item.loop_format = "liquid"
        item.limit = 15
        item.loop_liquid = node.loop_liquid
        item.sort = "released -1"

        page = author_node.pages.find_by(name: title)
        item.summary_page = page

        puts item.name
        item.save!

        pages[title].to_a.each do |page|
          puts "- #{page.name}"
          page.add_to_set(category_ids: item.id)
        end
      end
    end

    def destroy_authors
      Pippi::Joruri::Relation::OdekakeAuthor.each_with_index do |item, idx|
        puts "#{idx}.#{item.joruri_url}"
        item.owner_item.destroy if item.owner_item
        item.destroy
      end
    end

    def save_html_and_files(item, user, embedder, file_paths, file_filenames, file_names)
      return if file_paths.blank?

      files = []
      file_paths.each_with_index do |path, idx|
        path = "joruri_files/upload_files/#{::File.basename(path)}"
        filename = file_filenames[idx]
        name = file_names[idx]
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

    def import_odekake_docs
      csv = CSV.open("import_odekake_#{Time.zone.now.to_i}.csv",'w')
      path = ::File.join(csv_path, "odekake/odekake.csv")
      odekake_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      odekake_csv.each_with_index do |row, idx|
        original_id = row["id"]
        published_at = row["公開日"]
        title = row["記事タイトル"]
        created_at = row["created_at"]
        updated_at = row["updated_at"]
        body = row["body"]
        author_page = row["執筆者ページ有"]
        author_text = row["執筆者ページ無"]
        facility_page = row["施設情報ページ有"]
        facility_text = row["施設情報ページ無"]
        area1 = row["区"]
        category = row["カテゴリ"]
        child_age = row["一緒に行った子どもの年齢"].to_s.split("\n")
        group = row["グループ"]
        user = row["作成者"]
        state = row["state"]
        related_page = row["関連記事"]
        tag = row["かなタグ"]
        memo = row["作業メモ"]
        original_url = row["url"]
        file_urls = row["ファイルパス"].to_s.split("\n")
        file_paths = row["ファイルパス（内部）"].to_s.split("\n")
        file_filenames = row["ファイル名（内部）"].to_s.split("\n")
        file_names = row["ファイル表記（内部）"].to_s.split("\n")

        node = odekake_nodes[category]
        category = odekake_categories[category]
        area = odekake_areas[area1]
        group = groups[group]
        user = groups[user]

        layout = node.page_layout
        form = node.st_form_default

        rel_Joruri = Pippi::Joruri::Relation::Odekake.where(joruri_id: original_id).first
        if rel_Joruri
          item = rel_Joruri.owner_item
          next
        else
          item = Article::Page.new
          rel_Joruri = Pippi::Joruri::Relation::Odekake.new
        end

        item.cur_site = site
        item.cur_node = node
        item.cur_user = user
        item.layout = layout
        item.form = form
        item.group_ids = [group.id]
        item.name = title
        item.created = created_at
        item.updated = updated_at

        if published_at.present?
          item.released_type = "fixed"
          item.released = published_at
          item.first_released = published_at
        end

        item.state = (state == "draft") ? "closed" : "public"
        item.category_ids = [category.id, area.id]

        column_values = form.columns.order_by(order: 1).map { |column| column.value_type.new(column: column) }
        column_values[0].value = area1
        column_values[1].values = child_age if child_age.present?
        column_values[2].value = body
        column_values[3].page_id = nil
        column_values[4].value = author_text if author_text.present?
        column_values[5].page_id = nil
        column_values[6].value = facility_text if facility_text.present?
        column_values[7].value = memo if memo.present?

        item.form = form
        item.column_values = column_values

        puts "#{idx}.[#{category.name}] #{item.name}"
        def item.set_updated; end
        def item.serve_static_file?; false end
        item.save!

        # save joruri relation
        rel_Joruri.owner_item = item
        rel_Joruri.joruri_id = original_id
        rel_Joruri.joruri_url = original_url
        rel_Joruri.joruri_updated = updated_at
        rel_Joruri.save!

        save_html_and_files(item, user, item.column_values[2], file_paths, file_filenames, file_names)
        csv << [::File.join(site.full_url, item.private_show_path), item.full_url, category.name, rel_Joruri.joruri_url]
        csv.flush
      end
    end

    def destroy_odekake_docs
      Pippi::Joruri::Relation::Odekake.each_with_index do |item, idx|
        puts "#{idx}.#{item.joruri_url}"
        item.owner_item.destroy if item.owner_item
        item.destroy
      end
    end

    def save_html_and_files(item, user, embedder, file_paths, file_filenames, file_names)
      return if file_paths.blank?

      files = []
      file_filenames = file_filenames.map { |filename| ext_downcase(filename) }

      file_paths.each_with_index do |path, idx|
        path = "joruri_files/0114/upload_files/#{::File.basename(path)}"
        filename = file_filenames[idx]
        name = file_names[idx]
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

    def ext_downcase(filename)
      basename, ext = filename.split(".")
      [basename, ext.to_s.downcase].join(".")
    end

    def restore_relations_odekake_docs
      csv1 = CSV.open("fix_relations_links_#{Time.zone.now.to_i}.csv",'w')
      csv2 = CSV.open("fix_relations_author_#{Time.zone.now.to_i}.csv",'w')
      csv3 = CSV.open("fix_relations_facility_#{Time.zone.now.to_i}.csv",'w')
      csv4 = CSV.open("fix_relations_related_page_#{Time.zone.now.to_i}.csv",'w')

      path = ::File.join(csv_path, "odekake/odekake.csv")
      odekake_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      odekake_csv.each_with_index do |row, idx|
        original_id = row["id"]
        rel_joruri = Pippi::Joruri::Relation::Odekake.find_by(joruri_id: original_id)
        item = rel_joruri.owner_item
        dir = rel_joruri.joruri_url.sub(joruri_base_url, "")

        puts "#{idx}.[#{item.parent.name}] #{item.name}"

        # 執筆者ページ有
        author_page = row["執筆者ページ有"]
        if author_page.present?
          page = author_node.pages.where(name: author_page).first
          if page
            item.column_values[3].page_id = page.id
            csv2 << [::File.join(site.full_url, item.private_show_path), item.full_url, item.name, "ページ有り", author_page]
            csv2.flush
          else
            csv2 << [::File.join(site.full_url, item.private_show_path), item.full_url, item.name, "ページが見つからない", author_page]
            csv3.flush
          end
        end

        # 施設情報ページ有
        facility_page = row["施設情報ページ有"]
        if facility_page.present?
          page = Article::Page.site(site).where(filename: /^shisetsu\//).where(name: facility_page).first
          if page
            item.column_values[5].page_id = page.id
            csv3 << [::File.join(site.full_url, item.private_show_path), item.full_url, item.name, "ページ有り", facility_page]
            csv3.flush
          else
            csv3 << [::File.join(site.full_url, item.private_show_path), item.full_url, item.name, "ページが見つからない", facility_page]
            csv3.flush
          end
        end

        # 関連記事
        related_pages = row["関連記事"].to_s.split("\n")
        pages = []
        related_pages.each do |related_page|
          page = Article::Page.site(site).where(name: related_page).first
          if page
            pages << page
            csv4 << [::File.join(site.full_url, item.private_show_path), item.full_url, item.name, "ページ有り", related_page]
            csv4.flush
          else
            csv4 << [::File.join(site.full_url, item.private_show_path), item.full_url, item.name, "ページが見つからない", related_page]
            csv4.flush
          end
        end
        item.related_page_ids = pages.map(&:id)

        # generic links
        html = item.column_values[2].value
        html = restore_links(html, dir) do |src, dist, action|
          csv1 << [::File.join(site.full_url, item.private_show_path), item.full_url, item.name, src, dist, action]
          csv1.flush
        end
        item.column_values[2].value = html

        def item.set_updated; end
        def item.serve_static_file?; false end
        item.save!
      end
    end

    def restore_links(html, dir, &block)
      html.to_s.gsub(/(href|src)="(.*?)"/) do |matched|
        protocol = $1
        uri = ::Addressable::URI.parse($2) rescue nil

        if uri.nil?
          # invalid uri
          yield(matched, nil, "不正なURL")
          next matched
        end

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
  end
end
