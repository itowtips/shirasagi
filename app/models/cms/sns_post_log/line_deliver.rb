class Cms::SnsPostLog::LineDeliver < Cms::SnsPostLog::Line
  field :deliver_name, type: String
  field :deliver_mode, type: String, default: "main"
  embeds_ids :members, class_name: 'Cms::Member'

  def deliver_mode_options
    I18n.t("cms.options.deliver_mode").map { |k, v| [v, k] }
  end

  def extract_deliver_members
    members
  end

  private

  def set_name
    super
    self.deliver_name ||= "[#{label(:deliver_mode)}] #{source.try(:name)}"
  end

  class << self
    def search(params)
      criteria = self.where({})
      return criteria if params.blank?

      if params[:keyword].present?
        criteria = criteria.keyword_in params[:keyword], :deliver_name
      end
      criteria
    end
  end
end
