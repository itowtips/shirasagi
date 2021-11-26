module Pippi::Hamasuku::Importer
  class Node < Base
    attr_reader :group, :user, :layout

    def initialize(site)
      super(site)
      @group = SS::Group.find_by(name: "認定NPO法人はままつ子育てネットワークぴっぴ")
      @user = SS::User.find_by(name: "システム管理者")
      @layout = Cms::Layout.site(site).find_by(name: "カテゴリ/ページリスト（知りたい・相談したい・つながりたい・年別・区・キーワード）")
    end

    def save_category(filename, name, klass)
      puts name

      item = Category::Node::Base.site(site).where(filename: filename).first
      item ||= klass.new

      item.filename = filename
      item.name = name
      item.cur_site = site
      item.cur_user = user
      item.layout = layout
      item.group_ids = [group.id]
      item.state = "public"
      item.save!
    end

    def import_categories
      save_category("sodan/hamasukuqa/category", "カテゴリ", Category::Node::Node)

      save_category("sodan/hamasukuqa/category/trouble", "悩みから探す", Category::Node::Node)
      save_category("sodan/hamasukuqa/category/trouble/life", "生活", Category::Node::Page)
      save_category("sodan/hamasukuqa/category/trouble/karada", "からだ", Category::Node::Page)
      save_category("sodan/hamasukuqa/category/trouble/kotoba", "ことば", Category::Node::Page)
      save_category("sodan/hamasukuqa/category/trouble/communication", "コミュニケーション", Category::Node::Page)
      save_category("sodan/hamasukuqa/category/trouble/asobi", "あそび", Category::Node::Page)
      save_category("sodan/hamasukuqa/category/trouble/kodo", "気になる行動", Category::Node::Page)
      save_category("sodan/hamasukuqa/category/trouble/education", "しつけ・教育", Category::Node::Page)
      save_category("sodan/hamasukuqa/category/trouble/oya", "親の悩み", Category::Node::Page)
      save_category("sodan/hamasukuqa/category/trouble/shogai", "障がい", Category::Node::Page)

      save_category("sodan/hamasukuqa/category/age", "年齢から探す", Category::Node::Node)
      save_category("sodan/hamasukuqa/category/age/ninshin", "妊娠中", Category::Node::Page)
      save_category("sodan/hamasukuqa/category/age/0_3month", "0〜3か月", Category::Node::Page)
      save_category("sodan/hamasukuqa/category/age/4_6month", "4〜6か月", Category::Node::Page)
      save_category("sodan/hamasukuqa/category/age/7_12month", "7〜12か月", Category::Node::Page)
      save_category("sodan/hamasukuqa/category/age/1sai", "1歳", Category::Node::Page)
      save_category("sodan/hamasukuqa/category/age/2sai", "2歳", Category::Node::Page)
      save_category("sodan/hamasukuqa/category/age/3_4sai", "3～4歳", Category::Node::Page)
      save_category("sodan/hamasukuqa/category/age/5_6sai", "5〜6歳", Category::Node::Page)
    end
  end
end
