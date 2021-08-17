module Cms::Addon
  module CheckLinks
    extend ActiveSupport::Concern
    extend SS::Addon

    def check_links_error
      latest_report = Cms::CheckLinks::Report.site(site).first

      if self.class.include?(Cms::Model::Page)
        Cms::CheckLinks::Error::Page.where(report_id: latest_report.id, page_id: id).first
      elsif self.class.include?(Cms::Model::Node)
        Cms::CheckLinks::Error::Node.where(report_id: latest_report.id, node_id: id).first
      else
        nil
      end
    end
  end
end
