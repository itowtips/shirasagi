class Idportal::Agents::Nodes::SearchController < ApplicationController
  include Cms::NodeFilter::View
  helper Cms::ListHelper

  after_action :render_highlight

  def set_mysql_client
    @client = Idportal::Db.client
  end

  def set_keywords
    @keywords = params.dig(:s, :keyword).to_s.split(/[\s　]+/).uniq.compact
  end

  def search_mysql
    @res = []
    return if @keywords.blank?

    words = @keywords.map { |w| ::Regexp.escape(w) }

    set_mysql_client
    query = "SELECT * FROM resource00 "
    query += "WHERE "

    query += "("
    query += words.map do |w|
      "(title LIKE '%#{w}%' OR abstract LIKE '%#{w}%')"
    end.join(" OR ")
    query += ") "

    query += "AND "
    query += "FIND_IN_SET('idp', disp) "
    query += "AND "
    query += "NOT FIND_IN_SET('disable', disp) "
    query += "ORDER BY category, date DESC;"

    @res = @client.query(query)
  end

  def search_pages
    @items = []
    return if @keywords.blank?

    words = @keywords.map { |w| /#{::Regexp.escape(w)}/i }
    words = words[0..4]

    fields = [:name]
    cond = words.map { |word| fields.map { |field| { field => word } } }.flatten
    cond = { "$or" => cond }

    @items = Cms::Page.site(@cur_site).and_public(@cur_date).
      where(@cur_node.condition_hash).
      and(cond).
      page(params[:page]).
      per(@cur_node.limit)
  end

  def render_highlight
    return if @keywords.blank?

    words = @keywords.map { |w| ERB::Util.html_escape(w) }

    body = response.body
    body.gsub!(/>.+?</) do |text|
      words.each do |word|
        text.gsub!(word, replaced_word(word))
      end
      text
    end

    response.body = body.to_s
  end

  def replaced_word(word)
    '<span class="search-everything-highlight-color" style="background-color:orange">' + word + '</span>'
  end

  def index
    @res = []

    set_keywords
    search_mysql
    search_pages
  end
end
