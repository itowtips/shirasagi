class Pippi::Tips::Importer
  include ActiveModel::Model
  include Cms::CsvImportBase

  cattr_accessor(:model) { Pippi::Tips }
  self.required_headers = %w(date html ssml).map { |k| model.t(k) }

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
    date = row[t("date")].to_s.strip
    html = row[t("html")].to_s
    ssml = row[t("ssml")].to_s
    raise "日付が入力されていません。" if date.blank?

    begin
      date = parse_date(date)
    rescue ArgumentError => e
      raise "日付が不正です。(#{date})"
    end

    item = Pippi::Tips.find_or_initialize_by(site_id: site.id, node_id: node.id, date: date)
    item.user = user
    item.html = html
    item.ssml = ssml
    raise item.errors.full_messages.join(", ") if !item.save
    item
  end

  def parse_date(date)
    format1 = /^(\d+)\/(\d+)$/
    format2 = /^(\d+)#{I18n.t("datetime.prompts.month")}(\d+)#{I18n.t("datetime.prompts.day")}$/

    m = nil
    d = nil
    [format1, format2].each do |format|
      m, d = date.scan(format).flatten
      break if (m.numeric? && d.numeric?)
    end

    if !(m.numeric? && d.numeric?)
      raise ArgumentError.new
    end
    Date.new(year, m.to_i, d.to_i)
  end
end
