class Cms::CheckLinks::Error::Base
  include SS::Document
  include SS::Reference::Site
  include Cms::GroupPermission

  set_permission_name "cms_check_links_errors"

  belongs_to :report, class_name: "Cms::CheckLinks::Report"

  field :name, type: String
  field :filename, type: String
  field :full_url, type: String
  field :urls, type: Array, default: []

  validates :name, presence: true
  validates :report_id, presence: true

  def content
  end

  def group_label
    names = groups.pluck(:name).sort_by { |name| name.count("/") * -1 }
    label = names.first
    label += " ..." if names.size >= 2
    label
  end

  class << self
    def content_name
    end

    def and_report(report)
      where(report_id: report.id)
    end

    def search(params = {})
      criteria = all
      return criteria if params.blank?

      if params[:keyword].present?
        criteria = criteria.keyword_in(params[:keyword], :name, :filename)
      end

      criteria
    end

    def enum_csv
      criteria = self.all
      Enumerator.new do |y|
        criteria.each do |item|
          line = []
          line << item.full_url
          line << item.name
          line << item.groups.pluck(:name).join("\n")
          item.urls.each do |url|
            line << url
          end
          y << (line.to_csv).encode("SJIS", invalid: :replace, undef: :replace)
        end
      end
    end
  end
end
