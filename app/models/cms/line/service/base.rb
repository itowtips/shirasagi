class Cms::Line::Service::Base
  include SS::Document
  include SS::Reference::Site
  include SS::Reference::User
  include Cms::SitePermission

  store_in collection: "cms_line_services"

  set_permission_name "cms_line_services", :use

  field :name, type: String
  field :service, type: String
  field :order, type: Integer, default: 0
  permit_params :name, :service, :order

  validate :validate_name

  default_scope ->{ order_by(order: 1) }

  def service_options
    self.class.service_options
  end

  def switch_messages
    [
      {
        type: "text",
        text: "「#{name}」に切り替わりました。"
      }
    ]
  end

  def processor(site, node, client, request)
    klass = "Cms::Line::Service::Processor::#{service.classify}".constantize rescue nil
    item = klass.new(
      service: self,
      site: site,
      node: node,
      client: client,
      request: request)
    item.parse_request
    item
  end

  def delegate_processor(delegator, events)
    klass = "Cms::Line::Service::Processor::#{service.classify}".constantize rescue nil
    item = klass.new(
      service: self,
      site: delegator.site,
      node: delegator.node,
      client: delegator.client,
      request: delegator.request
    )
    item.signature = delegator.signature
    item.body = delegator.body
    item.events = events
    item.event_session = delegator.event_session
    item
  end

  private

  def validate_name
    self.name = label(:service)
    errors.add :name, :invalid if name.blank?
  end

  class << self
    def service_options
      services = [
        Cms::Line::Service::Hub,
        Cms::Line::Service::FacilitySearch,
        Cms::Line::Service::GdChat,
        Cms::Line::Service::MyPlan,
      ].map { |klass| klass.name.sub(/^#{Cms::Line::Service}(\:\:)?/, "").underscore }

      services.map { |k| [I18n.t("cms.options.line_services.#{k}"), k] }
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
