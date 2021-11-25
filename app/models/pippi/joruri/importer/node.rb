module Pippi::Joruri::Importer
  class Node < Base
    attr_reader :user, :group, :layouts

    def initialize(site)
      super(site)
      @group = SS::Group.find_by(name: "認定NPO法人はままつ子育てネットワークぴっぴ")
      @user = SS::User.find_by(name: "システム管理者")

      @layouts = {}
      ["ぴっぴのブログ ＞ ページリスト用", "ぴっぴのブログ ＞ 記事ページ"].each do |name|
        @layouts[name] = Cms::Layout.site(site).find_by(name: name)
      end
    end

    def import_nodes
=begin
      # 子育てヒント タグ 忘れない3.11
      filename = "blog/hint/tag/wasurenai311"
      name = "忘れない3.11"

      original_id = 1
      original_url = "https://www.hamamatsu-pippi.net/shiritai/blog/bosai/cat/b311/more.html"
      puts "#{original_id}.#{name}"

      rel_Joruri = Pippi::Joruri::Relation::Node.where(joruri_id: original_id).first
      if rel_Joruri
        item = rel_Joruri.owner_item
      else
        item = Category::Node::Page.new
        rel_Joruri = Pippi::Joruri::Relation::Node.new
      end

      item.filename = filename
      item.name = name
      item.site = site
      item.cur_user = user
      item.layout = @layouts["ぴっぴのブログ ＞ ページリスト用"]
      item.page_layout = @layouts["ぴっぴのブログ ＞ 記事ページ"]
      item.group_ids = [group.id]
      item.state = "public"
      item.save!

      # save joruri relation
      rel_Joruri.owner_item = item
      rel_Joruri.joruri_id = original_id
      rel_Joruri.joruri_url = original_url
      rel_Joruri.save!
=end
      # save other relations
      relations = {}
      relations[2] = ["/shiritai/blog/", "blog"]
      relations[3] = ["/shiritai/blog/hint/", "blog/hint"]
      relations[4] = ["/shiritai/blog/odekake/", "blog/odekake"]
      relations[5] = ["/shiritai/koza/", "shiritai/koza"]
      relations[6] = ["/shiritai/ichioshi/hamamatsu/", "blog/report/category/hamamatsu"]
      relations[7] = ["/shiritai/blog/hint/cat/ryorirecipe/more.html", "blog/hint/category/recipe"]
      relations[8] = ["/shiritai/blog/hint/cat/ha/more.html", "blog/hint/category/kenkou"]
      relations.each do |original_id, v|
        original_path = v[0]
        filename = v[1]
        original_url = ::File.join("https://www.hamamatsu-pippi.net/", original_path)
        item = Cms::Node.site(site).find_by(filename: filename)
        puts "#{original_id}.#{item.name}"

        rel_Joruri = Pippi::Joruri::Relation::Node.where(joruri_id: original_id).first
        rel_Joruri ||= Pippi::Joruri::Relation::Node.new
        rel_Joruri.owner_item = item
        rel_Joruri.joruri_id = original_id
        rel_Joruri.joruri_url = original_url
        rel_Joruri.save!
      end
    end
  end
end
