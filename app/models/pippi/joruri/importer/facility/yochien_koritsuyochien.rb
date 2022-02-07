module Pippi::Joruri::Importer::Facility
  class YochienKoritsuyochien < Pippi::Joruri::Importer::Base
    attr_reader :groups, :yochien_nodes

    def initialize(site)
      super(site)

      @groups = {}
      %w(認定NPO法人はままつ子育てネットワークぴっぴ).each do |name|
        @groups[name] = SS::Group.find_by(name: name)
      end

      ["システム管理者", "ぴっぴ 時田祐子", "ぴっぴ 森口", "ぴっぴ 仲子", "ぴっぴ 三輪", "ぴっぴ 村松", "ぴっぴ 藤田"].each do |name|
        @groups[name] = SS::User.find_by(name: name)
      end

      @yochien_nodes = {}
      %w(公立幼稚園一覧 私立幼稚園一覧).each do |name|
        @yochien_nodes[name] = Article::Node::Page.site(@site).find_by(filename: /^shiritai\/yoho\/yochien\/yochien\//, name: name)
      end
    end

    def import_facility_yochien_koritsuyochien_docs
      csv = CSV.open("import_facility_yochien_koritsuyochien_#{Time.zone.now.to_i}.csv",'w')
      path = ::File.join(csv_path, "facility/facilities.csv")
      facility_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      path = ::File.join(csv_path, "facility/yochien_koritsuyochien.csv")
      yochien_koritsuyochien_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      facility_csv.each_with_index do |row, idx|
        next unless row['category_id'] == '51'
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

        # node = yochien_nodes[category]
        node = yochien_nodes['公立幼稚園一覧']
        # category = yochien_nodes[category]
        category = yochien_nodes['公立幼稚園一覧']
        group = groups[group]
        user = groups[user]

        layout = node.page_layout
        form = node.st_form_default || node.st_forms.first

        rel_Joruri = Pippi::Joruri::Relation::Facility::YochienKoritsuyochien.where(joruri_id: original_id).first
        if rel_Joruri
          item = rel_Joruri.owner_item
          next
        else
          item = Article::Page.new
          rel_Joruri = Pippi::Joruri::Relation::Facility::YochienKoritsuyochien.new
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
        yochien_koritsuyochien_row = yochien_koritsuyochien_csv.find do |yochien_koritsuyochien_row|
          next true if yochien_koritsuyochien_row['施設名称'] == title
          yochien_koritsuyochien_row['所在地'].to_s.include?(row['place'])
        end
        column_values[0].value = yochien_koritsuyochien_row['施設名称']
        column_values[2].value = yochien_koritsuyochien_row['郵便番号']
        column_values[3].value = yochien_koritsuyochien_row['区']
        column_values[4].value = yochien_koritsuyochien_row['所在地']
        column_values[5].value = yochien_koritsuyochien_row['緯度']
        column_values[6].value = yochien_koritsuyochien_row['経度']
        column_values[7].value = yochien_koritsuyochien_row['電話番号']

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

    def destroy_facility_yochien_koritsuyochien_docs
      Pippi::Joruri::Relation::Facility::YochienKoritsuyochien.each_with_index do |item, idx|
        puts "#{idx}.#{item.joruri_url}"
        item.owner_item.destroy if item.owner_item
        item.destroy
      end
    end
  end
end
