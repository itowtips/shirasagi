class Pippi::Tips::Importer
  include ActiveModel::Model
  include Cms::CsvImportBase

  cattr_accessor(:model) { Pippi::Tips }
  self.required_headers = %w(date html).map { |k| model.t(k) }

  attr_reader :site, :node, :user, :year

  def initialize(site, node, user, year)
    @site = site
    @node = node
    @user = user
    @year = year
  end

  def import(file)
    import_csv(file)
  end

  def t(key)
    self.class.model.t(key)
  end

  def model
    self.class.model
  end

  private

  def import_csv(file)
    i = 0
    self.class.each_csv(file) do |row|
      begin
        i += 1
        update_row(row)
      rescue => e
        self.errors.add :base, "#{i + 1}: #{e}"
      end
    end
    errors.empty?
  end

  def update_row(row)
    date = row[t("date")]
    html = row[t("html")]
    raise "日付が入力されていません。" if date.blank?

    begin
      ary = date.split("/").map(&:to_i)
      if ary.size != 2 && ary.size != 3
        raise ArgumentError.new
      end

      month = ary[-2]
      day = ary[-1]
      if month.nil? || day.nil? || month == 0 || day == 0
        raise ArgumentError.new
      end
      date = Date.new(year, month, day)
    rescue ArgumentError => e
      raise "日付が不正です。(#{date})"
    end

    item = Pippi::Tips.find_or_initialize_by(site_id: site.id, node_id: node.id, date: date)
    item.user = user
    item.html = html
    raise item.errors.full_messages.join(", ") if !item.save
    item
  end
end
