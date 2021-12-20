module Pippi::Joruri::Importer
  class Library < Base
    attr_reader :user, :group, :node

    def initialize(site)
      super(site)

      @user = SS::User.find_by(name: "システム管理者")
      @group = SS::Group.find_by(name: "認定NPO法人はままつ子育てネットワークぴっぴ")
      @node = Article::Node::Page.site(@site).find_by(filename: "shisetsu/toshokan", name: "図書館")
    end

    def import_map_libraries
      csv = CSV.open("import_map_liburaies_#{Time.zone.now.to_i}.csv",'w')

      path = ::File.join(csv_path, "map/library.csv")
      circle_csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      circle_csv.each_with_index do |row, idx|
        title = row["図書館名"]
        postal_code = row["郵便番号"]
        address = row["所在地"]
        tel = row["電話"]
        lat = row["緯度"]
        lon = row["経度"]
        no = row["NO"]
        area1 = row["区"]
        original_id = no.to_i

        rel_Joruri = Pippi::Joruri::Relation::Library.where(joruri_id: original_id).first
        if rel_Joruri
          item = rel_Joruri.owner_item
        else
          item = Article::Page.new
          rel_Joruri = Pippi::Joruri::Relation::Library.new
        end

        layout = node.page_layout
        form = node.st_form_default

        # save article
        item.cur_site = site
        item.cur_node = node
        item.cur_user = user
        item.name = title
        item.form = form
        item.layout = layout
        item.group_ids = [group.id]
        item.state = "public"

        column_values = form.columns.order_by(order: 1).map { |column| column.value_type.new(column: column) }
        column_values[2].value = area1
        column_values[4].value = postal_code
        column_values[5].value = address
        column_values[6].value = tel
        column_values[13].value = no

        item.form = form
        item.column_values = column_values
        item.map_points = [{ name: "", loc: [lon, lat], text: "" }]
        puts "#{idx}. #{item.name}"
        item.save!

        # save joruri relation
        rel_Joruri.owner_item = item
        rel_Joruri.joruri_id = original_id
        rel_Joruri.save!

        csv << [::File.join(site.full_url, item.private_show_path), item.full_url]
        csv.flush
      end
    end

    def destroy_map_libraries
      Pippi::Joruri::Relation::Library.each_with_index do |item, idx|
        puts "#{idx}.#{item.joruri_url}"
        item.owner_item.destroy if item.owner_item
        item.destroy
      end
    end
  end
end
