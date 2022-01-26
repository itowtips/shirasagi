module Pippi::Joruri::Importer
  class PippiContent < Base
    attr_reader :groups, :users, :node, :nenrei_categories, :case_categories, :chiiki_categories

    def initialize(site)
      super(site)

      @groups = {}
      %w(認定NPO法人はままつ子育てネットワークぴっぴ).each do |name|
        @groups[name] = SS::Group.find_by(name: name)
      end

      @users = {}
      ["システム管理者"].each do |name|
        @groups[name] = SS::User.find_by(name: name)
      end

      @node = Article::Node::Page.site(@site).find_by(filename: "contents", name: "サイトコンテンツの記事")

      @nenrei_categories = Category::Node::Base.where(filename: /^nenrei\//).to_a.map { |item| [item.name, item] }.to_h
      @case_categories = Category::Node::Base.where(filename: /^case\//).to_a.map { |item| [item.name, item] }.to_h
      @chiiki_categories = Category::Node::Base.where(filename: /^chiiki\//).to_a.map { |item| [item.name, item] }.to_h
    end

    def find_optional_categories(row)
      categories = []
      if row["妊娠"] == "●"
        categories << nenrei_categories["妊娠中"]
      end
      if row["赤"] == "●"
        categories << nenrei_categories["赤ちゃん"]
      end
      if row["1"] == "●"
        categories << nenrei_categories["1～2歳"]
        categories << nenrei_categories["1歳"]
      end
      if row["2"] == "●"
        categories << nenrei_categories["1～2歳"]
        categories << nenrei_categories["2歳"]
      end
      if row["3"] == "●"
        categories << nenrei_categories["3〜5歳"]
        categories << nenrei_categories["3歳"]
      end
      if row["4"] == "●"
        categories << nenrei_categories["3〜5歳"]
        categories << nenrei_categories["4歳"]
      end
      if row["5"] == "●"
        categories << nenrei_categories["3〜5歳"]
        categories << nenrei_categories["5歳"]
      end
      if row["小学"] == "●"
        categories << nenrei_categories["小学生以上"]
      end
      if row["障が"] == "●"
        categories << case_categories["障がい"]
      end
      if row["ひとり"] == "●"
        categories << case_categories["ひとり親"]
      end
      if row["未熟児"] == "●"
        categories << case_categories["未熟児"]
      end
      if row["多胎児"] == "●"
        categories << case_categories["多胎児"]
      end
      if row["引越し"] == "●"
        categories << case_categories["引越し"]
      end
      if row["働く"] == "●"
        categories << case_categories["働く"]
      end
      if row["子育てを支援する"] == "●"
        categories << case_categories["子育てを支援する"]
      end
      if row["中"] == "●"
        categories << chiiki_categories["中区"]
      end
      if row["東"] == "●"
        categories << chiiki_categories["東区"]
      end
      if row["西"] == "●"
        categories << chiiki_categories["西区"]
      end
      if row["南"] == "●"
        categories << chiiki_categories["南区"]
      end
      if row["北"] == "●"
        categories << chiiki_categories["北区"]
      end
      if row["浜北"] == "●"
        categories << chiiki_categories["浜北区"]
      end
      if row["天竜"] == "●"
        categories << chiiki_categories["天竜区"]
      end
      categories
    end

    def find_contact_group(row)
      name = row["問市"].to_s.squish
      return if name.blank?

      name = name.gsub("　", " ")
      name = name.gsub(" ", "/")

      if name == "NPO法人はままつ子育てネットワークぴっぴ"
        name = "認定NPO法人はままつ子育てネットワークぴっぴ"
      elsif name == "ぴっぴ"
        name = "認定NPO法人はままつ子育てネットワークぴっぴ"
      elsif name == "ファミリーサポートセンター"
        name = "ファミリー・サポート・センター"
      end

      group = Cms::Group.find_by(name: name)
      group
    end

    def import_pippi_contents
      csv = CSV.open("import_pippi_contents_#{Time.zone.now.to_i}.csv",'w')

      pages = {}
      path = ::File.join(csv_path, "pippi_contents_docs.csv")
      contents_docs_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      contents_docs_csv.each_with_index do |row, idx|
        id = row["id"]
        title = row["title"]
        body = row["body"]
        url = row["url"]
        file_urls = row["file_urls"]
        file_paths = row["file_paths"]
        file_filenames = row["file_filenames"]
        file_names = row["file_names"]
        pages[url] = {
          id: id,
          title: title,
          body: body,
          url: url,
          file_urls: file_urls.to_s.split("\n"),
          file_paths: file_paths.to_s.split("\n"),
          file_filenames: file_filenames.to_s.split("\n"),
          file_names: file_names.to_s.split("\n")
        }
      end

      cate1 =  nil
      cate2 =  nil
      cate3 =  nil
      path = ::File.join(csv_path, "pippi_contents.csv")
      imported_urls = []

      contents_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      contents_csv.each_with_index do |row, idx|
        title1 = row["新サイト第一階層"]
        title2 = row["第二階層"]
        title3 = row["第三階層"]
        title4 = row["第四階層"]
        type = row["移行区分"]
        url = row["現URL"]

        title = title1.presence || title2.presence || title3.presence || title4.presence
        depth = 0
        depth = 1 if title1.present?
        depth = 2 if title2.present?
        depth = 3 if title3.present?
        depth = 4 if title4.present?

        item = nil
        # フォルダー
        if type == "フォルダー"
          filename = row["フォルダー名"]

          if title1.present?
            cate = Cms::Node.site(site).where(filename: filename).first
            cate1 = cate
            cate2 = nil
            cate3 = nil
          end
          if title2.present?
            cate = Cms::Node.site(site).where(filename: filename).first
            cate2 = cate
            cate3 = nil
          end
          if title3.present?
            cate = Cms::Node.site(site).where(filename: filename).first
            cate3 = cate
          end

          if cate.nil?
            raise "not found: #{title} (#{filename})"
          end
        elsif type == "記事ページ"
          optional_categories = find_optional_categories(row)
          contact_group = find_contact_group(row)

          category = nil
          if depth == 3
            category = cate2
          elsif depth == 4
            category = cate3
          end

          if imported_urls.include?(url)
            item = add_category(idx, pages[url], category, optional_categories, contact_group)
          else
            item = import_doc(idx, pages[url], category, optional_categories, contact_group)
          end
          imported_urls << url
        end

        if item
          csv << [::File.join(site.full_url, item.private_show_path), item.full_url]
        else
          csv << []
        end
      end
    end

    def import_doc(idx, attr, category, optional_categories, contact_group)
      original_id = attr[:id]
      title = attr[:title]
      body = attr[:body]
      original_url = attr[:url]
      file_urls = attr[:file_urls]
      file_paths = attr[:file_paths]
      file_filenames = attr[:file_filenames]
      file_names = attr[:file_names]
      created_at = attr[:created_at]
      updated_at = attr[:updated_at]
      published_at = attr[:published]

      group = groups["認定NPO法人はままつ子育てネットワークぴっぴ"]
      user = users["システム管理者"]
      layout = node.page_layout
      form = node.st_form_default

      rel_Joruri = Pippi::Joruri::Relation::PippiContent.where(joruri_id: original_id).first
      if rel_Joruri
        item = rel_Joruri.owner_item
      else
        item = Article::Page.new
        rel_Joruri = Pippi::Joruri::Relation::PippiContent.new
      end

      item.cur_site = site
      item.cur_node = node
      item.cur_user = user
      item.layout = layout
      item.form = form
      item.group_ids = contact_group ? [group.id, contact_group.id] : [group.id]
      item.name = title
      item.created = created_at
      item.updated = updated_at
      item.released_type = "fixed"
      item.released = published_at
      item.first_released = published_at
      item.category_ids = [category.id] + optional_categories.map(&:id)

      if contact_group
        item.contact_group = contact_group
        item.contact_tel = contact_group.contact_tel
        item.contact_email = contact_group.contact_email
      end

      column_values = form.columns.where(name: "自由入力").order_by(order: 1).map { |column| column.value_type.new(column: column) }
      column_values[0].value = body

      item.form = form
      item.column_values = column_values

      puts "#{idx}.[#{node.name}] #{item.name}"
      def item.set_updated; end
      def item.serve_static_file?; false end
      item.save!

      save_html_and_files(item, user, item.column_values[0], file_paths, file_filenames, file_names)

      # save joruri relation
      rel_Joruri.owner_item = item
      rel_Joruri.joruri_id = original_id
      rel_Joruri.joruri_url = original_url
      rel_Joruri.joruri_updated = updated_at
      rel_Joruri.save!

      item
    end

    def add_category(idx, attr, category, optional_categories, contact_group)
      original_id = attr[:id]
      title = attr[:title]
      rel_Joruri = Pippi::Joruri::Relation::PippiContent.where(joruri_id: original_id).first
      item = rel_Joruri.owner_item
      item.category_ids = item.category_ids.to_a + [category.id] + optional_categories.map(&:id)

      puts "#{idx}. add category [#{category.name}] #{title}"
      def item.set_updated; end
      def item.serve_static_file?; false end
      item.save!
      item
    end

    def destroy_pippi_contents
      Pippi::Joruri::Relation::PippiContent.each_with_index do |item, idx|
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

    def restore_relations_pippi_contents
      csv = CSV.open("fix_relations_pippi_contents_#{Time.zone.now.to_i}.csv",'w')

      Pippi::Joruri::Relation::PippiContent.each_with_index do |rel_Joruri, idx|
        item = rel_Joruri.owner_item
        dir = rel_Joruri.joruri_url.sub(joruri_base_url, "")
        puts "#{idx}.#{item.name}"

        html = item.column_values[0].value

        # generic links
        html = restore_links(html, dir) do |src, dist, action|
          csv << [::File.join(site.full_url, item.private_show_path), item.full_url, rel_Joruri.joruri_url, src, dist, action]
          csv.flush
        end

        item.column_values[0].value = html

        def item.set_updated; end
        #def item.serve_static_file?; false end
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
