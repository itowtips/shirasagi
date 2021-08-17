class Cms::CheckLinks::Error::Page < Cms::CheckLinks::Error::Base
  belongs_to :page, class_name: "Cms::Page"

  set_permission_name "cms_check_links_errors"

  def content
    page
  end

  class << self
    def content_name
      "ページ"
    end
  end
end
