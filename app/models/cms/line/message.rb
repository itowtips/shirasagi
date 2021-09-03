class Cms::Line::Message
  include SS::Document
  include SS::Reference::User
  include SS::Reference::Site
  include Cms::Addon::Line::Message::Body
  include Cms::Addon::Line::Message::DeliverCondition
  include Cms::Addon::Line::Message::DeliverPlan
  include Cms::Addon::GroupPermission
  #include History::Addon::Backup

  set_permission_name "cms_line_templates"

  seqid :id
  field :name, type: String

  field :state, type: String, default: "closed"
  field :deliver_state, type: String, default: "draft"

  field :released, type: DateTime
  field :first_released, type: DateTime
  field :completed, type: DateTime
  field :test_completed, type: DateTime

  permit_params :name

  validates :name, presence: true
  validate :validate_condition_body, if: ->{ deliver_condition_state == "multicast_with_input_condition" }

  def private_show_path(*args)
    options = args.extract_options!
    options = options.merge(site: cur_site || site, id: self)
    helper_mod = Rails.application.routes.url_helpers
    helper_mod.cms_line_message_path(*args, options)
  end

  def public?
    state == "public"
  end

  def ready?
    deliver_state == "ready"
  end

  def completed?
    deliver_state == "completed"
  end

  def publish
    self.state = "public"
    self.released = Time.zone.now
    self.first_released ||= released
    return false unless self.valid?

    templates.each_with_index do |template, idx|
      next if template.valid?
      template.errors.full_messages.each do |msg|
        self.errors.add :base, "本文#{idx + 1}: #{msg}"
      end
    end
    return false if errors.present?

    self.save
    templates.each(&:save)
    true
  end

  def deliver
    return false unless publish

    self.deliver_state = "ready"
    if !(deliver_date && deliver_date > Time.zone.now)
      self.deliver_date = nil
    end
    return false unless self.save

    if !deliver_date
      Cms::Line::DeliverJob.bind(site_id: site.id).perform_later(id)
    end
    true
  end

  def test_deliver(members)
    return false unless publish

    Cms::Line::TestDeliverJob.bind(site_id: site.id).perform_later(id, members.map(&:id))
    true
  end

  def deliver_state_options
    I18n.t("cms.options.deliver_state").map { |k, v| [v,  k] }
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
