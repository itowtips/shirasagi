module Pippi::Joruri::Importer::Facility
  class GakushushienGakusyukyoshitsu < Pippi::Joruri::Importer::Base
    attr_reader :groups, :gakushushien_nodes

    def initialize(site)
      super(site)

      @groups = {}
      %w(認定NPO法人はままつ子育てネットワークぴっぴ).each do |name|
        @groups[name] = SS::Group.find_by(name: name)
      end

      ["システム管理者", "ぴっぴ 時田祐子", "ぴっぴ 森口", "ぴっぴ 仲子", "ぴっぴ 三輪", "ぴっぴ 村松", "ぴっぴ 藤田"].each do |name|
        @groups[name] = SS::User.find_by(name: name)
      end

      @gakushushien_nodes = {}
      %w(はままつ子どもの学習教室 民間学習支援).each do |name|
        @gakushushien_nodes[name] = Article::Node::Page.site(@site).find_by(filename: /^tsunagaru\/gakushushien\//, name: name)
      end
    end

    def import_facility_gakushushien_gakusyukyoshitsu_docs
      csv = CSV.open("import_facility_gakushushien_gakusyukyoshitsu_#{Time.zone.now.to_i}.csv",'w')
      path = ::File.join(csv_path, "facility/facilities.csv")
      facility_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      path = ::File.join(csv_path, "facility/gakushushien_gakusyukyoshitsu.csv")
      gakushushien_gakusyukyoshitsu_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      facility_csv.each_with_index do |row, idx|
        next unless row['category_id'] == '92'
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

        node = gakushushien_nodes[category]
        category = gakushushien_nodes[category]
        group = groups[group]
        user = groups[user]

        layout = node.page_layout
        form = node.st_form_default || node.st_forms.first

        rel_Joruri = Pippi::Joruri::Relation::Facility::GakushushienGakusyukyoshitsu.where(joruri_id: original_id).first
        if rel_Joruri
          item = rel_Joruri.owner_item
          next
        else
          item = Article::Page.new
          rel_Joruri = Pippi::Joruri::Relation::Facility::GakushushienGakusyukyoshitsu.new
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
        gakushushien_gakusyukyoshitsu_row = gakushushien_gakusyukyoshitsu_csv.find do |gakushushien_gakusyukyoshitsu_row|
          next true if gakushushien_gakusyukyoshitsu_row['名称'] == title
          row['place'].to_s.include?(gakushushien_gakusyukyoshitsu_row['所在地_住所2'])
        end
        column_values[0].value = gakushushien_gakusyukyoshitsu_row['名称']
        column_values[1].value = gakushushien_gakusyukyoshitsu_row['カナ']
        column_values[2].value = gakushushien_gakusyukyoshitsu_row['郵便番号']
        column_values[3].value = gakushushien_gakusyukyoshitsu_row['区']
        column_values[4].value = gakushushien_gakusyukyoshitsu_row['所在地_住所1']
        column_values[5].value = gakushushien_gakusyukyoshitsu_row['所在地_住所2']
        column_values[6].value = gakushushien_gakusyukyoshitsu_row['緯度']
        column_values[7].value = gakushushien_gakusyukyoshitsu_row['経度']
        column_values[8].value = gakushushien_gakusyukyoshitsu_row['電話']
        column_values[9].link_url = gakushushien_gakusyukyoshitsu_row['URL']
        column_values[10].value = gakushushien_gakusyukyoshitsu_row['運営者']
        column_values[11].value = gakushushien_gakusyukyoshitsu_row['開催曜日']
        column_values[12].value = gakushushien_gakusyukyoshitsu_row['開催時間']
        column_values[13].value = gakushushien_gakusyukyoshitsu_row['開催日時備考']
        column_values[14].value = gakushushien_gakusyukyoshitsu_row['活動内容']
        column_values[15].value = gakushushien_gakusyukyoshitsu_row['対象者']
        column_values[16].value = gakushushien_gakusyukyoshitsu_row['利用料']
        column_values[17].value = gakushushien_gakusyukyoshitsu_row['定員']
        column_values[18].value = gakushushien_gakusyukyoshitsu_row['参加状況
更新日']
        column_values[19].value = gakushushien_gakusyukyoshitsu_row['登録人数']
        column_values[20].value = gakushushien_gakusyukyoshitsu_row['空き状況']
        column_values[21].value = gakushushien_gakusyukyoshitsu_row['申込方法']
        column_values[22].value = gakushushien_gakusyukyoshitsu_row['活動内容']

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

    def destroy_facility_gakushushien_gakusyukyoshitsu_docs
      Pippi::Joruri::Relation::Facility::GakushushienGakusyukyoshitsu.each_with_index do |item, idx|
        puts "#{idx}.#{item.joruri_url}"
        item.owner_item.destroy if item.owner_item
        item.destroy
      end
    end
  end
end
