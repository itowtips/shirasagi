module Pippi::Joruri::Importer::Facility
  class ByogojiMinkanbyoji < Pippi::Joruri::Importer::Base
    attr_reader :groups, :byogoji_nodes

    def initialize(site)
      super(site)

      @groups = {}
      %w(認定NPO法人はままつ子育てネットワークぴっぴ).each do |name|
        @groups[name] = SS::Group.find_by(name: name)
      end

      ["システム管理者", "ぴっぴ 時田祐子", "ぴっぴ 森口", "ぴっぴ 仲子", "ぴっぴ 三輪", "ぴっぴ 村松", "ぴっぴ 藤田"].each do |name|
        @groups[name] = SS::User.find_by(name: name)
      end

      @byogoji_nodes = {}
      %w(病児・病後児保育（浜松市委託事業）一覧 その他の民間病児・病後児保育一覧).each do |name|
        @byogoji_nodes[name] = Article::Node::Page.site(@site).find_by(filename: /^shiritai\/ichiji_hoiku\/byogoji\//, name: name)
      end
    end

    def import_facility_byogoji_minkanbyoji_docs
      csv = CSV.open("import_facility_byogoji_minkanbyoji_#{Time.zone.now.to_i}.csv",'w')
      path = ::File.join(csv_path, "facility/facilities.csv")
      facility_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      path = ::File.join(csv_path, "facility/byogoji_minkanbyoji.csv")
      byogoji_minkanbyoji_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      facility_csv.each_with_index do |row, idx|
        next unless row['category_id'] == '90'
        original_id = row["id"]
        published_at = row["published_at"]
        title = row["title"]
        created_at = row["created_at"]
        updated_at = row["updated_at"]
        body = row["body"]
        category = row["category_name"]
        group = row["creator_group_name"]
        user = row["creator_user_name"]
        state = row["state"]
        original_url = row["public_full_uri"]

        # node = byogoji_nodes[category]
        node = byogoji_nodes['その他の民間病児・病後児保育一覧']
        # category = byogoji_nodes[category]
        category = byogoji_nodes['その他の民間病児・病後児保育一覧']
        group = groups[group]
        user = groups[user]

        layout = node.page_layout
        form = node.st_form_default || node.st_forms.first

        rel_Joruri = Pippi::Joruri::Relation::Facility::ByogojiMinkanbyoji.where(joruri_id: original_id).first
        if rel_Joruri
          item = rel_Joruri.owner_item
          next
        else
          item = Article::Page.new
          rel_Joruri = Pippi::Joruri::Relation::Facility::ByogojiMinkanbyoji.new
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
        # item.category_ids = [category.id, area.id]

        column_values = form.columns.order_by(order: 1).map { |column| column.value_type.new(column: column) }
        byogoji_minkanbyoji_row = byogoji_minkanbyoji_csv.find do |byogoji_minkanbyoji_row|
          byogoji_minkanbyoji_row['名称'] == title
        end
        column_values[0].value = byogoji_minkanbyoji_row['名称']
        column_values[1].value = byogoji_minkanbyoji_row['カナ']
        # if byogoji_minkanbyoji_row['画像URL'].present?
        #   path = "joruri_files/byogoji/#{::File.basename(byogoji_minkanbyoji_row['画像URL'])}"
        #   raise "not found #{path}" if !::File.exists?(path)
        #
        #   ss_file = SS::File.new
        #   ss_file.in_file = Fs::UploadedFile.create_from_file(path)
        #   ss_file.site = site
        #   ss_file.user = user
        #   ss_file.filename = ::File.basename(byogoji_minkanbyoji_row['画像URL'])
        #   ss_file.model = item.class.name
        #   ss_file.owner_item = item
        #   ss_file.save!
        #   ss_file.set(content_type: ::Fs.content_type(byogoji_minkanbyoji_row['画像URL']))
        #   column_values[2].file_id = ss_file.id
        # end
        column_values[3].value = byogoji_minkanbyoji_row['郵便番号']
        column_values[4].value = byogoji_minkanbyoji_row['区']
        column_values[5].value = byogoji_minkanbyoji_row['所在地_住所1']
        column_values[6].value = byogoji_minkanbyoji_row['所在地_住所2']
        column_values[7].value = byogoji_minkanbyoji_row['緯度']
        column_values[8].value = byogoji_minkanbyoji_row['経度']
        column_values[9].value = byogoji_minkanbyoji_row['電話番号']
        column_values[10].link_url = byogoji_minkanbyoji_row['URL']
        column_values[11].values = byogoji_minkanbyoji_row['保育内容'].to_s.split("\n")
        column_values[12].value = byogoji_minkanbyoji_row['備考']

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

        csv << [::File.join(site.full_url, item.private_show_path), item.full_url, category.name, rel_Joruri.joruri_url]
        csv.flush
      end
    end

    def destroy_facility_byogoji_minkanbyoji_docs
      Pippi::Joruri::Relation::Facility::ByogojiMinkanbyoji.each_with_index do |item, idx|
        puts "#{idx}.#{item.joruri_url}"
        item.owner_item.destroy if item.owner_item
        item.destroy
      end
    end
  end
end
