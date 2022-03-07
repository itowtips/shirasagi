module Gws::Addon::Portal::Portlet::PresetSetting
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    field :managed, type: String, default: "managed"
    field :required, type: String, default: "default"
    field :show_default, type: String, default: "show"
    field :description, type: String
    field :order, type: Integer, default: 0
    permit_params :managed, :required, :show_default, :description, :order
    before_validation :set_managed
  end

  private

  def set_managed
    if managed?
      # 管理者設定する
      # 必須設定が決められる。初期表示が決められる
      # ただし、必須の場合は、必ず表示する
      self.show_default = "show" if required?
    else
      # 利用者が設定する
      # 必ず任意になる
      self.required = "optional"
    end
  end

  public

  def managed_options
    [
      [I18n.t('gws/portal.options.managed.managed'), 'managed'],
      [I18n.t('gws/portal.options.managed.unmanaged'), 'unmanaged'],
    ]
  end

  def required_options
    [
      [I18n.t('ss.options.state.required'), 'required'],
      [I18n.t('ss.options.state.optional'), 'optional'],
    ]
  end

  def show_default_options
    [
      [I18n.t("ss.options.state.show"), "show"],
      [I18n.t("ss.options.state.hide"), "hide"],
    ]
  end

  def required?
    required == "required"
  end

  def show_default?
    show_default == "show"
  end

  def managed?
    managed == "managed"
  end

  def order
    value = self[:order].to_i
    value < 0 ? 0 : value
  end

  def initialize_by_preset_addons
    Gws::Portal::PresetSynchronization::INITIALIZE_BY_PRESET_PORTLETS.map do |model|
      "addon-gws-agents-addons-portal-portlet-#{model}"
    end
  end
end
