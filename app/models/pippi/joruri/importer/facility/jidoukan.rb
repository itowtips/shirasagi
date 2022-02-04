module Pippi::Joruri::Importer::Facility
  class Jidoukan < Pippi::Joruri::Importer::Base
    attr_reader :groups, :jidoukan_nodes

    def initialize(site)
      super(site)

      @groups = {}
      %w(認定NPO法人はままつ子育てネットワークぴっぴ).each do |name|
        @groups[name] = SS::Group.find_by(name: name)
      end

      ["システム管理者", "ぴっぴ 時田祐子", "ぴっぴ 森口", "ぴっぴ 仲子", "ぴっぴ 三輪", "ぴっぴ 村松", "ぴっぴ 藤田"].each do |name|
        @groups[name] = SS::User.find_by(name: name)
      end

      @jidoukan_nodes = {}
      %w(児童館).each do |name|
        @jidoukan_nodes[name] = Article::Node::Page.site(@site).find_by(filename: /^tsunagaru\/hiroba\//, name: name)
      end
    end

    def import_facility_jidoukan_docs
      csv = CSV.open("import_facility_jidoukan_#{Time.zone.now.to_i}.csv",'w')
      path = ::File.join(csv_path, "facility/facilities.csv")
      facility_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      path = ::File.join(csv_path, "facility/jidoukan.csv")
      jidoukan_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      facility_csv.each_with_index do |row, idx|
        next unless row['category_id'] == '45'
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

        node = jidoukan_nodes[category]
        category = jidoukan_nodes[category]
        # group = groups[group]
        group = groups['認定NPO法人はままつ子育てネットワークぴっぴ']
        user = groups[user]

        layout = node.page_layout
        form = node.st_form_default || node.st_forms.first

        rel_Joruri = Pippi::Joruri::Relation::Facility::Jidoukan.where(joruri_id: original_id).first
        if rel_Joruri
          item = rel_Joruri.owner_item
          next
        else
          item = Article::Page.new
          rel_Joruri = Pippi::Joruri::Relation::Facility::Jidoukan.new
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
        jidoukan_row = jidoukan_csv.find do |jidoukan_row|
          next true if jidoukan_row['名称'] == title
          jidoukan_row['緯度'] == row['lat'] && jidoukan_row['経度'] == row['lng']
        end
        column_values[0].value = jidoukan_row['名称']
        column_values[1].value = jidoukan_row['カナ']
        column_values[2].value = jidoukan_row['郵便番号']
        column_values[3].value = jidoukan_row['区']
        column_values[4].value = jidoukan_row['所在地_住所1']
        column_values[5].value = jidoukan_row['所在地_住所2']
        column_values[6].value = jidoukan_row['緯度']
        column_values[7].value = jidoukan_row['経度']
        column_values[8].value = jidoukan_row['電話']
        column_values[9].link_url = jidoukan_row['URL']
        column_values[10].value = jidoukan_row['開催日']
        column_values[11].value = jidoukan_row['開催時間']
        column_values[12].values = jidoukan_row['利用料 '].to_s.split("\n")
        column_values[13].value = jidoukan_row['駐車場 ']

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

    def destroy_facility_jidoukan_docs
      Pippi::Joruri::Relation::Facility::Jidoukan.each_with_index do |item, idx|
        puts "#{idx}.#{item.joruri_url}"
        item.owner_item.destroy if item.owner_item
        item.destroy
      end
    end
  end
end
