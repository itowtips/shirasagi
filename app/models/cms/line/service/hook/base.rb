module Cms::Line::Service::Hook
  class Base
    include SS::Document
    include SS::Reference::Site
    include SS::Reference::User
    include Cms::SitePermission

    store_in collection: "cms_line_service_hooks"

    set_permission_name "cms_line_services", :use

    field :name, type: String
    field :service, type: String
    field :trigger_type, type: String
    field :trigger_data, type: String
    field :order, type: Integer, default: 0
    permit_params :name, :service, :trigger_type, :trigger_data, :order

    belongs_to :group, class_name: "Cms::Line::Service::Group", inverse_of: :hooks

    validates :name, presence: true, length: { maximum: 40 }
    validates :group_id, presence: true
    validates :trigger_type, presence: true
    validates :trigger_data, presence: true

    default_scope ->{ order_by(order: 1) }

    def service_options
      self.class.service_options
    end

    def trigger_type_options
      %w(message postback).map { |k| [I18n.t("cms.options.line_action_type.#{k}"), k] }
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

    def delegate_processor(delegator, event)
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
      item.events = [event]
      item.event_session = delegator.event_session
      item
    end

    # HUB
    def service_name
      name
    end

    def switch_mode(processor, event)
      return false if event["type"] != trigger_type

      case trigger_type
      when "message"
        return false if event["message"]["text"] != trigger_data
      when "postback"
        return false if event["postback"]["data"] != trigger_data
      else
        return false
      end

      processor.event_session.mode = service_name
      processor.event_session.update

      delegate_processor(processor, event).start
      return true
    end

    def delegate(processor, event)
      return false if processor.event_session.mode != service_name
      delegate_processor(processor, event).call
      true
    end

    private

    class << self
      def service_options
        services = [
          Cms::Line::Service::Hook::FacilitySearch,
          Cms::Line::Service::Hook::Chat,
          Cms::Line::Service::Hook::GdChat,
          Cms::Line::Service::Hook::MyPlan,
          Cms::Line::Service::Hook::JsonTemplate,
        ].map { |klass| klass.name.sub(/^#{Cms::Line::Service::Hook}(\:\:)?/, "").underscore }

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
end
