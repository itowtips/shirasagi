module Pippi::Joruri::Importer::Facility
  class GakudoHoukagojidoukai < Pippi::Joruri::Importer::Base
    attr_reader :groups, :gakudo_nodes

    def initialize(site)
      super(site)

      @groups = {}
      %w(認定NPO法人はままつ子育てネットワークぴっぴ).each do |name|
        @groups[name] = SS::Group.find_by(name: name)
      end

      ["システム管理者", "ぴっぴ 時田祐子", "ぴっぴ 森口", "ぴっぴ 仲子", "ぴっぴ 三輪", "ぴっぴ 村松", "ぴっぴ 藤田"].each do |name|
        @groups[name] = SS::User.find_by(name: name)
      end

      @gakudo_nodes = {}
      %w(放課後児童会 類似放課後児童クラブ その他の民間学童保育).each do |name|
        @gakudo_nodes[name] = Article::Node::Page.site(@site).find_by(filename: /^shiritai\/hokagoibasho\/gakudo\//, name: name)
      end
    end

    def import_facility_gakudo_houkagojidoukai_docs
      csv = CSV.open("import_facility_gakudo_houkagojidoukai_#{Time.zone.now.to_i}.csv",'w')
      path = ::File.join(csv_path, "facility/facilities.csv")
      facility_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      path = ::File.join(csv_path, "facility/gakudo_houkagojidoukai.csv")
      gakudo_houkagojidoukai_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      facility_csv.each_with_index do |row, idx|
        next unless row['category_id'] == '54'
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

        node = gakudo_nodes[category]
        category = gakudo_nodes[category]
        group = groups[group]
        user = groups[user]

        layout = node.page_layout
        form = node.st_form_default || node.st_forms.first

        rel_Joruri = Pippi::Joruri::Relation::Facility::GakudoHoukagojidoukai.where(joruri_id: original_id).first
        if rel_Joruri
          item = rel_Joruri.owner_item
          next
        else
          item = Article::Page.new
          rel_Joruri = Pippi::Joruri::Relation::Facility::GakudoHoukagojidoukai.new
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
        gakudo_houkagojidoukai_row = gakudo_houkagojidoukai_csv.find do |gakudo_houkagojidoukai_row|
          next true if gakudo_houkagojidoukai_row['名称'] == title
          gakudo_houkagojidoukai_row['電話番号'] == row['tel']
        end
        column_values[0].value = gakudo_houkagojidoukai_row['名称']
        column_values[1].value = gakudo_houkagojidoukai_row['カナ']
        column_values[2].value = gakudo_houkagojidoukai_row['郵便番号']
        column_values[3].value = gakudo_houkagojidoukai_row['区']
        column_values[4].value = gakudo_houkagojidoukai_row['所在地_住所1']
        column_values[5].value = gakudo_houkagojidoukai_row['所在地_住所2']
        column_values[6].value = gakudo_houkagojidoukai_row['開設場所']
        column_values[7].value = gakudo_houkagojidoukai_row['使用種別']
        column_values[8].value = gakudo_houkagojidoukai_row['緯度']
        column_values[9].value = gakudo_houkagojidoukai_row['経度']
        column_values[10].value = gakudo_houkagojidoukai_row['電話番号']
        column_values[11].link_url = gakudo_houkagojidoukai_row['URL']
        column_values[12].value = gakudo_houkagojidoukai_row['設置主体'] || gakudo_houkagojidoukai_row['運営団体']
        column_values[13].value = gakudo_houkagojidoukai_row['指定小学校'] || gakudo_houkagojidoukai_row['学区']
        column_values[14].value = gakudo_houkagojidoukai_row['対象']
        column_values[15].value = gakudo_houkagojidoukai_row['定員']
        column_values[16].values = gakudo_houkagojidoukai_row['開設日'].to_s.split("\n")
        column_values[17].value = gakudo_houkagojidoukai_row['開所時間（平日）'] || gakudo_houkagojidoukai_row['開設時間_平日']
        column_values[18].value = gakudo_houkagojidoukai_row['閉所時間（平日）']
        column_values[19].value = gakudo_houkagojidoukai_row['開所時間（長期）'] || gakudo_houkagojidoukai_row['開設時間_その他']
        column_values[20].value = gakudo_houkagojidoukai_row['閉所時間（長期）']
        column_values[21].value = gakudo_houkagojidoukai_row['費用']
        column_values[22].values = gakudo_houkagojidoukai_row['スタッフの資格'].to_s.split("\n")
        column_values[23].value = gakudo_houkagojidoukai_row['特色・PR']
        column_values[24].value = gakudo_houkagojidoukai_row['備考']

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

    def destroy_facility_gakudo_houkagojidoukai_docs
      Pippi::Joruri::Relation::Facility::GakudoHoukagojidoukai.each_with_index do |item, idx|
        puts "#{idx}.#{item.joruri_url}"
        item.owner_item.destroy if item.owner_item
        item.destroy
      end
    end
  end
end
