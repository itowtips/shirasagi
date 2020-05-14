class Idportal::Agents::Nodes::PageController < ApplicationController
  include Cms::NodeFilter::View

  def set_mysql_client
    @client = Idportal::Db.client
  end

  def set_subs
    @subs = []

    query = "SELECT * FROM sub order by sortid;"

    subs = @client.query(query)
    subs.each do |sub|
      if sub["name"] == "学術論文（審査不明）"
        next
      elsif sub["name"] == "カテゴリ不明"
        @subs << sub.merge({ "label" => "その他" })
      else
        @subs << sub.merge({ "label" => sub["name"] })
      end
    end
  end

  def set_res
    @res_years = {}

    query = "SELECT * FROM resource00 "
    query += "WHERE "
    query += "category REGEXP '^#{Regexp.escape(@cur_kw)}' "
    query += "AND "
    query += "sub REGEXP '^#{Regexp.escape(@cur_skw)}' "
    query += "AND "
    query += "FIND_IN_SET('idp', disp) "
    query += "AND "
    query += "NOT FIND_IN_SET('disable', disp) "
    query += "ORDER BY category, date DESC;"

    res = @client.query(query)
    res.each do |row|
      date = row["date"]
      next if date.nil?
      next if date.year <= 1970

      year = date.year
      year -= 1 if date.month < 4

      @res_years[year] ||= []
      @res_years[year] << row
    end

    @res = @cur_year ? @res_years[@cur_year.to_i] : res
  end

  def index
    @cur_kw = "文献"
    @cur_skw = params[:skw].presence || "学術論文（審査あり）"
    @cur_skw_label = (@cur_skw == "カテゴリ不明") ? "その他" : @cur_skw
    @cur_year = params[:year].presence

    set_mysql_client
    set_subs
    set_res
  end
end
