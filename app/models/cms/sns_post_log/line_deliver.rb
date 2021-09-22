class Cms::SnsPostLog::LineDeliver < Cms::SnsPostLog::Line
  include Cms::Addon::GroupPermission

  set_permission_name "cms_line_messages", :use

  field :deliver_name, type: String
  field :deliver_mode, type: String, default: "main"
  embeds_ids :members, class_name: 'Cms::Member'

  def deliver_mode_options
    I18n.t("cms.options.deliver_mode").map { |k, v| [v, k] }
  end

  def extract_deliver_members
    members
  end

  def root_owned?(user)
    true
  end

  private

  def set_name
    super
    self.deliver_name ||= "[#{label(:deliver_mode)}] #{source.try(:name)}"
  end

  class << self
    def create_with(item)
      log = self.new
      log.site = item.site
      log.source_name = item.name
      log.source = item
      log.group_ids = item.group_ids
      yield(log)
      log.save
    end

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
