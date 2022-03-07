module Gws::Portal
  class Preset
    include SS::Document
    include SS::Fields::Normalizer
    include Gws::Referenceable
    include Gws::Reference::User
    include Gws::Reference::Site
    include Gws::Addon::Member
    include Gws::SitePermission
    include Gws::Addon::History

    class_variable_set(:@@_member_ids_required, false)

    set_permission_name "gws_portal_preset", :manage

    seqid :id
    field :name, type: String
    field :order, type: Integer
    field :portal_type, type: String, default: "user"
    permit_params :name, :order, :portal_type

    has_one :portal_setting, class_name: 'Gws::Portal::PresetSetting', dependent: :destroy

    validates :portal_type, presence: true

    after_save :save_portal_setting

    default_scope -> { order_by(order: 1, name: 1) }

    def order
      value = self[:order].to_i
      value < 0 ? 0 : value
    end

    def portal_type_options
      [
        [I18n.t("gws/portal.options.portal_type.user"), "user"],
        [I18n.t("gws/portal.options.portal_type.group"), "group"],
        [I18n.t("gws/portal.options.portal_type.organization"), "organization"]
      ]
    end

    private

    def save_portal_setting
      setting = portal_setting || Gws::Portal::PresetSetting.new
      setting.cur_site = site
      setting.portal_preset = self
      setting.name = name
      setting.save!
    end

    class << self
      def find_portal_preset(site, target)
        member_id = nil
        member_group_id = nil
        portal_type = nil

        if target.is_a?(Gws::User)
          portal_type = "user"
          member_id = target.id
          main_group = target.gws_main_group(site)
          member_group_id = main_group.id if main_group
        end
        if target.is_a?(Gws::Group)
          portal_type = target.organization? ? "organization" : "group"
          member_group_id = target.id
        end

        if member_id
          preset = self.site(site).where(portal_type: portal_type).in(member_ids: member_id).first
          return preset if preset
        end
        if member_group_id
          preset = self.site(site).where(portal_type: portal_type).in(member_group_ids: member_group_id).first
          return preset if preset
        end

        self.site(site).where({
          "$and" => [
            { portal_type: portal_type },
            { "$or" => [{ :member_ids.exists => false }, { :member_ids => [] }] },
            { "$or" => [{ :member_group_ids.exists => false }, { :member_group_ids => [] }] }
          ]
        }).first
      end

      def search(params = {})
        criteria = self.where({})
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
