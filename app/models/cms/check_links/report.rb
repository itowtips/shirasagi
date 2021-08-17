class Cms::CheckLinks::Report
  include SS::Document
  include SS::Reference::Site
  include Cms::SitePermission

  set_permission_name "cms_check_links_reports"

  seqid :id
  field :name, type: String

  has_many :link_errors, foreign_key: "report_id", class_name: "Cms::CheckLinks::Error::Base", dependent: :destroy

  before_save :set_name

  default_scope ->{ order_by(created: -1) }

  private

  def set_name
    self.name ||= "リンクチェック実行結果 \##{id}"
  end

  public

  def name_with_site
    "[#{site.try(:name)}] #{name}"
  end

  def pages
    Cms::CheckLinks::Error::Page.and_report(self)
  end

  def nodes
    Cms::CheckLinks::Error::Node.and_report(self)
  end

  def save_error(ref, urls)
    filename = ref.sub(/^#{::Regexp.escape(site.url)}/, "")
    filename.sub!(/\?.*$/, "")
    filename += "index.html" if ref.match?(/\/$/)

    page = Cms::Page.site(site).where(filename: filename).first
    if page
      cond = { site_id: site.id, report_id: self.id, page_id: page.id }
      item = Cms::CheckLinks::Error::Page.find_or_initialize_by(cond)
      item.name = page.name
      item.filename = page.filename
      item.full_url = page.full_url
      item.urls = (item.urls.to_a + urls).uniq
      item.group_ids = (item.group_ids.to_a + page.group_ids.to_a).uniq
      return item.save
    end

    filename.sub!(/\/(index\.html)?$/, "")
    node = Cms::Node.site(site).where(filename: filename).first
    if node
      cond = { site_id: site.id, report_id: self.id, node_id: node.id }
      item = Cms::CheckLinks::Error::Node.find_or_initialize_by(cond)
      item.name = node.name
      item.filename = node.filename
      item.full_url = node.full_url
      item.urls = (item.urls.to_a + urls).uniq
      item.group_ids = (item.group_ids.to_a + node.group_ids.to_a).uniq
      return item.save
    end

    return false
  end

  class << self
    def search(params = {})
      criteria = all
      return criteria if params.blank?

      if params[:keyword].present?
        criteria = criteria.keyword_in(params[:keyword], :name)
      end

      criteria
    end
  end
end
