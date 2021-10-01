class Pippi::TipsYear
  include SS::Document
  include SS::Reference::User
  include SS::Reference::Site
  include Cms::Reference::Node
  include Cms::SitePermission

  set_permission_name "cms_line_deliver_categories", :use

  seqid :id
  field :name, type: String
  field :year, type: Integer
  permit_params :name, :year

  validates :year, presence: true
  before_save :set_name

  def days_enum_csv(options = {})
    first_day = Date.new(year, 1, 1)
    last_day = Date.new(year, 12, 1).end_of_month
    headers = %w(date text).map { |k| Pippi::Tips.t(k) }
    Enumerator.new do |y|
      y << encode_sjis(headers.to_csv)
      (first_day..last_day).each do |day|
        row = []
        row << day.strftime("%Y/%m/%d")
        y << encode_sjis(row.to_csv)
      end
    end
  end

  def encode_sjis(str)
    str.encode("SJIS", invalid: :replace, undef: :replace)
  end

  private

  def set_name
    self.name = "#{year}#{I18n.t("ss.options.datetime_unit.year")}"
  end

  class << self
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
