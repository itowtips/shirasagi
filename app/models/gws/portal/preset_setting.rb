class Gws::Portal::PresetSetting
  include SS::Document
  include Gws::Referenceable
  include Gws::Reference::User
  include Gws::Reference::Site
  include Gws::Portal::PortalModel
  include Gws::SitePermission
  include Gws::Addon::History

  index({ portal_preset_id: 1, site_id: 1 }, { unique: true })

  set_permission_name "gws_portal_preset", :manage

  attr_accessor :portal_user

  field :name, type: String
  belongs_to :portal_preset, class_name: 'Gws::Portal::Preset'
  has_many :portlets, class_name: 'Gws::Portal::PresetPortlet', dependent: :destroy

  permit_params :name

  validates :name, presence: true
  validates :portal_preset_id, presence: true, uniqueness: { scope: :site_id }

  def portlet_models
    if portal_preset.portal_type == "user"
      Gws::Portal::UserSetting.new.portlet_models
    else
      Gws::Portal::GroupSetting.new.portlet_models
    end
  end

  def required_portlets
    portlets.select(&:required?)
  end

  def default_portlets
    portlets.select(&:show_default?)
  end
end
