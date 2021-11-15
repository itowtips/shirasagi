class Pippi::Tips
  include SS::Document
  include SS::Reference::User
  include SS::Reference::Site
  include Cms::Reference::Node
  include Cms::Addon::Ssml
  include Cms::SitePermission

  set_permission_name "pippi_tips"

  seqid :id
  field :name, type: String
  field :date, type: DateTime
  field :year, type: Integer
  field :month, type: Integer
  field :day, type: Integer
  field :html, type: String
  permit_params :name, :date, :html

  validates :date, presence: true
  before_save :set_name
  before_save :set_ymd

  def summary
    ApplicationController.helpers.sanitize(html.presence || '', tags: []).squish.html_safe.truncate(120)
  end

  def layout
    @_layout ||= begin
      self.class.find_layout(site, node, date) || "nil"
    end
    (@_layout == "nil") ? nil : @_layout
  end

  def render_layout
    return html if layout.nil?
    rendered = layout.html.presence || "{{ yield }}"
    rendered.gsub!("{{ yield }}", html)

    %w(image1 image2 image3).each do |key|
      image = layout.send(key)
      img_tag = image ? "<img src=\"#{image.url}\" alt=\"#{image.name}\">" : ""
      rendered.gsub!("{{ #{key} }}", img_tag)
    end
    rendered
  end

  private

  def set_name
    self.name = "#{date.strftime("%Y/%m/%d")} のひとこと"
  end

  def set_ymd
    self.year = date.year
    self.month = date.month
    self.day = date.day
  end

  class << self
    def find_layout(site, node, date)
      Pippi::TipsLayout.site(site).node(node).where(start_date: { "$lte" => date }, end_date: { "$gte" => date }).first
    end

    def search(params)
      criteria = all
      return criteria if params.blank?

      if params[:name].present?
        criteria = criteria.search_text params[:name]
      end
      if params[:keyword].present?
        criteria = criteria.keyword_in params[:keyword], :name
      end
      criteria
    end
  end
end
