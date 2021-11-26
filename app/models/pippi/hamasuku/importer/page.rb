module Pippi::Hamasuku::Importer
  class Page < Base
    attr_reader :faq_node, :article_node, :users, :hamasuku_users, :group, :categories

    def initialize(site)
      super(site)
      @faq_node = Faq::Node::Page.site(site).find_by(filename: "sodan/hamasukuqa/hamasukuqa-list")
      #@article_node = Article::Node::Page.site(site).find_by(filename: "sodan/hamasukuqa/oshirase")
      @group = SS::Group.find_by(name: "認定NPO法人はままつ子育てネットワークぴっぴ")

      @users = {}
      ["システム管理者", "ぴっぴ 三輪", "ぴっぴ 藤田", "ぴっぴ 時田祐子"].each do |name|
        @users[name] = SS::User.find_by(name: name)
      end
      @hamasuku_users = Pippi::Hamasuku::SS::User.all.to_a.index_by { |item| item.id }

      @categories = {}
      ["悩み", "生活", "からだ", "ことば", "コミュニケーション", "あそび", "気になる行動", "しつけ・教育", "親の悩み", "障がい"].each do |name|
        @categories[name] = Category::Node::Base.where(filename: /^sodan\/hamasukuqa\//).find_by(name: name)
      end
      ["年齢", "妊娠中", "0〜3か月", "4〜6か月", "7〜12か月", "1歳", "2歳", "3〜4歳", "5〜6歳"].each do |name|
        @categories[name] = Category::Node::Base.where(filename: /^sodan\/hamasukuqa\//).find_by(name: name)
      end
    end

    def save_html_and_files(item, user, embedder, original_files)
      return if original_files.blank?

      # filename が一意にならないので削除する。
      item.files.destroy_all

      files = {}
      original_files.each_with_index do |original_file, idx|
        path = original_file.path
        filename = original_file.filename
        name = original_file.name
        puts "- #{filename}"

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
        files[original_file.url] = ss_file
      end
      file_ids = files.map { |url, ss_file| ss_file.id }

      # replace file paths
      html = embedder.instance_of?(Cms::Column::Value::Free) ? embedder.value.to_s : embedder.html.to_s
      html = html.gsub(/(href|src)="(.*?)"/) do |str|
        scheme = $1
        path = $2
        if path =~ /^\/fs\// && files[path]
          "#{scheme}=\"#{files[path].url}\""
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

    def import_faq_pages
      csv = CSV.open("import_faq_pages_#{Time.zone.now.to_i}.csv",'w')

      pages = Pippi::Hamasuku::Cms::Page.where(site_id: hamasuku_site_id, route: "faq/page").to_a
      pages.each_with_index do |page, idx|
        rel_hamasuku = Pippi::Hamasuku::Relation::Page.where(hamasuku_id: page.id).first
        if rel_hamasuku
          item = rel_hamasuku.owner_item
        else
          rel_hamasuku = Pippi::Hamasuku::Relation::Page.new
          item = Faq::Page.new
        end

        import_keys = %w(
          name index_name
          order
          parent_crumb_urls
          related_page_sort
          user_id group_ids
          question html
          contact_state contact_group_id
          created updated released first_released
          state)
        rel_keys = %w(access_count kana_tags related_page_ids)
        import_attributes = page.attributes.select { |k, _| import_keys.include?(k) }
        rel_attributes = page.attributes.select { |k, _| rel_keys.include?(k) }

        user_name = (@hamasuku_users[import_attributes["user_id"]])["name"]
        user_name = user_name.gsub(/^ぴっぴ/, "ぴっぴ ").gsub("時田", "時田祐子")
        user = SS::User.where(name: user_name).first
        raise "unknown user #{user_name}!" if user.nil?

        # save page
        item.attributes = import_attributes
        item.cur_site = site
        item.cur_node = faq_node
        item.cur_user = user
        item.released_type = "fixed"

        item.layout = faq_node.page_layout
        item.group_ids = [group.id]

        # categories
        category_ids = page.attributes["category_ids"]
        category_names = Pippi::Hamasuku::Cms::Node.in(id: category_ids).pluck(:name)
        item.category_ids = category_names.map do |name|
          name.gsub!("～", "〜")
          categories[name].id
        end

        puts "#{idx}.[FAQ] #{item.name}"
        def item.set_updated; end
        item.save!

        # save hamasuku relation
        rel_hamasuku.hamasuku_id = page.id
        rel_hamasuku.hamasuku_url = page.full_url
        rel_hamasuku.owner_item = item
        rel_hamasuku.attributes = rel_attributes
        rel_hamasuku.save!

        # save files
        file_ids = page.attributes["file_ids"]
        original_files = file_ids.map do |id|
          file = Pippi::Hamasuku::SS::File.find(id)
          OpenStruct.new(
            filename: file.filename,
            name: file.name,
            url: file.url,
            path: file.path
          )
        end
        save_html_and_files(item, user, item, original_files)

        csv << [::File.join(site.full_url, item.private_show_path), item.full_url, rel_hamasuku.hamasuku_url]
        csv.flush
      end
    end

    def restore_links(html, dir, &block)
      html.to_s.gsub(/(href|src)="(.*?)"/) do |matched|
        protocol = $1
        uri = ::Addressable::URI.parse($2)

        if uri.host && (uri.host != hamasuku_host && uri.host != joruri_host)
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

        url = ::File.join(hamasuku_base_url, Pathname(dir).join(uri.path))
        rel = Pippi::Hamasuku::Relation::Page.where(hamasuku_url: url).first

        if !rel
          url = ::File.join(joruri_base_url, Pathname(dir).join(uri.path))
          rel = Pippi::Joruri::Relation::Doc.where(joruri_url: url).first
        end

        if !rel
          # not found relation
          yield(uri.to_s, nil, "置換対象が存在しない")
          next matched
        end

        yield(uri.to_s, rel.owner_item.url, "リンク置換")
        "#{protocol}=\"#{rel.owner_item.url}\""
      end
    end

    def restore_relations_faq_pages
      csv = CSV.open("fix_relations_faq_pages_#{Time.zone.now.to_i}.csv",'w')

      Pippi::Hamasuku::Relation::Page.each_with_index do |rel, idx|
        item = rel.owner_item
        dir = rel.hamasuku_url.sub(hamasuku_base_url, "")
        html = item.html
        puts "#{idx}.#{item.name}"

        # generic links
        html = restore_links(html, dir) do |src, dist, action|
          csv << [::File.join(site.full_url, item.private_show_path), item.full_url, src, dist, action]
          csv.flush
        end
        item.html = html

        # related_page_ids
        if rel.related_page_ids.present?
          item.related_page_ids = rel.related_page_ids.map do |hamasuku_id|
            Pippi::Hamasuku::Relation::Page.where(hamasuku_id: hamasuku_id).first.try(:owner_item_id)
          end.compact
        end

        def item.set_updated; end
        item.save!
      end
    end

    def destroy_faq_pages
      Pippi::Hamasuku::Relation::Page.each_with_index do |item, idx|
        puts "#{idx}.#{item.hamasuku_url}"
        item.owner_item.destroy if item.owner_item
        item.destroy
      end
    end
  end
end
