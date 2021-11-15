class Pippi::Tips::Exporter
  include ActiveModel::Model

  UTF8_BOM = "\uFEFF".freeze

  cattr_accessor(:model) { Pippi::Tips }

  attr_reader :site, :node, :year

  def initialize(site, node, year, options = {})
    @site = site
    @node = node
    @year = year
    @encoding = options[:encoding].presence || "Shift_JIS"
  end

  def headers
    %w(date html ssml layout).map { |k| Pippi::Tips.t(k) }
  end

  def draw_header
    (@encoding == "Shift_JIS") ? encode_sjis(headers.to_csv) : UTF8_BOM + headers.to_csv
  end

  def draw_basic(day, item)
    row = []
    row << day.strftime("%m/%d")
    row << item.try(:html)
    row << item.try(:ssml)
    row << item.layout.try(:name)
    (@encoding == "Shift_JIS") ? encode_sjis(row.to_csv) : row.to_csv
  end

  def enum_csv(options = {})
    first_day = Date.new(year, 1, 1)
    last_day = Date.new(year, 12, 1).end_of_month
    items = Pippi::Tips.site(site).node(node).where(year: year).to_a
    items = items.map { |item| [item.date.to_date, item] }.to_h
    Enumerator.new do |y|
      y << draw_header
      (first_day..last_day).each do |day|
        item = items[day]
        y << draw_basic(day, item)
      end
    end
  end

  def content_type
    "text/csv; charset=#{@encoding}"
  end

  def encode_sjis(str)
    str.encode("SJIS", invalid: :replace, undef: :replace)
  end
end
