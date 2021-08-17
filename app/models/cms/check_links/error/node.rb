class Cms::CheckLinks::Error::Node < Cms::CheckLinks::Error::Base
  belongs_to :node, class_name: "Cms::Node"

  set_permission_name "cms_check_links_errors"

  def content
    node
  end

  class << self
    def content_name
      "フォルダー"
    end
  end
end
