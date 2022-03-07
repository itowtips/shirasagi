module Gws::Portal::PresetSynchronization
  extend ActiveSupport::Concern
  extend SS::Translation

  INITIALIZE_BY_PRESET_PORTLETS = [
    :reminder, :schedule, :todo, :bookmark, :board, :faq, :qna, :circular, :monitor,
    :share, :workflow, :notice, :presence, :survey
  ].freeze

  SYNCHRONIZE_BY_PRESET_PORTLETS = [
    :free, :links, :reminder, :schedule, :todo, :bookmark, :board, :faq, :qna, :circular,
    :monitor, :share, :workflow, :notice, :presence, :survey, :ad
  ].freeze

  included do
    field :preset_updated, type: DateTime
    belongs_to :preset_portlet, class_name: 'Gws::Portal::PresetPortlet'
    permit_params :preset_portlet_id
    before_validation :synchronize_by_preset
  end

  private

  def set_preset_params(portlet, *fields)
    fields.each do |field|
      value = portlet.send(field).dup
      self.send("#{field}=", value)
    end
  end

  def find_current_preset
    @_current_preset ||= begin
      site = setting.site
      target = setting.try(:portal_user) || setting.try(:portal_group)
      item = Gws::Portal::Preset.find_portal_preset(site, target)
      item || false
    end
  end

  def find_synchronized_preset
    @_synchronized_preset ||= begin
      item = preset_portlet.setting.portal_preset rescue nil
      item || false
    end
  end

  public

  def managed_label
    required_by_preset? ? I18n.t("ss.options.state.required") : ""
  end

  def managed_by_preset?
    # ポータル設定、元ポートレットが存在しない（削除された）
    return false unless preset_portlet

    # 元ポートレットが管理者設定でない
    return false unless preset_portlet.managed?

    # ポータル設定の参加者に該当しなくなった
    current_preset = find_current_preset
    synced_preset = find_synchronized_preset

    return false unless current_preset
    return false unless synced_preset
    return false if current_preset.id != synced_preset.id

    true
  end

  def required_by_preset?
    return false unless managed_by_preset?
    preset_portlet.required?
  end

  def initialize_by_preset(portlet)
    self.preset_portlet = portlet
    self.portlet_model = portlet.portlet_model.dup

    initialize_by_preset_basic(portlet)
    INITIALIZE_BY_PRESET_PORTLETS.each do |model|
      self.send("initialize_by_preset_#{model}", portlet)
    end
  end

  def synchronize_by_preset
    return unless managed_by_preset?

    # 元ポートレットが更新されているか
    return if preset_updated && preset_updated >= preset_portlet.updated
    self.preset_updated = preset_portlet.updated

    portlet = preset_portlet
    synchronize_by_preset_basic(portlet)
    SYNCHRONIZE_BY_PRESET_PORTLETS.each do |model|
      self.send("synchronize_by_preset_#{model}", portlet)
    end
  end

  ## initialize handlers
  def initialize_by_preset_basic(portlet)
    set_preset_params(portlet, :name, :limit)
  end

  def initialize_by_preset_reminder(portlet)
    set_preset_params(portlet, :reminder_filter)
  end

  def initialize_by_preset_schedule(portlet)
    set_preset_params(portlet, :schedule_member_mode, :schedule_member_ids)
  end

  def initialize_by_preset_todo(portlet)
    set_preset_params(portlet, :todo_state)
  end

  def initialize_by_preset_bookmark(portlet)
    set_preset_params(portlet, :bookmark_model)
  end

  def initialize_by_preset_board(portlet)
    set_preset_params(portlet, :board_severity, :board_browsed_state, :board_category_ids)
  end

  def initialize_by_preset_faq(portlet)
    set_preset_params(portlet, :faq_category_ids)
  end

  def initialize_by_preset_qna(portlet)
    set_preset_params(portlet, :qna_category_ids)
  end

  def initialize_by_preset_circular(portlet)
    set_preset_params(portlet, :circular_article_state, :circular_category_ids)
  end

  def initialize_by_preset_monitor(portlet)
    set_preset_params(portlet, :monitor_answerable_article, :monitor_category_ids)
  end

  def initialize_by_preset_share(portlet)
    set_preset_params(portlet, :share_folder_id, :share_category_ids)
  end

  def initialize_by_preset_workflow(portlet)
    set_preset_params(portlet, :workflow_state)
  end

  def initialize_by_preset_notice(portlet)
    set_preset_params(portlet, :notice_severity, :notice_browsed_state, :notice_category_ids, :notice_folder_ids)
  end

  def initialize_by_preset_presence(portlet)
    set_preset_params(portlet, :group_id, :custom_group_id)
  end

  def initialize_by_preset_survey(portlet)
    set_preset_params(portlet, :survey_answered_state, :survey_sort, :survey_category_ids)
  end

  ## synchronize handlers
  def synchronize_by_preset_basic(portlet)
    set_preset_params(portlet, :limit)
  end

  def synchronize_by_preset_free(portlet)
    set_preset_params(portlet, :html)
    self.file_ids = portlet.file_ids
    self.in_clone_file = true
  end

  def synchronize_by_preset_links(portlet)
    set_preset_params(portlet, :links)
  end

  def synchronize_by_preset_ad(portlet)
    set_preset_params(portlet, :ad_width, :ad_speed, :ad_pause)
    self.ad_file_ids = portlet.ad_file_ids
    self.in_clone_ad_file = true
  end

  alias synchronize_by_preset_reminder initialize_by_preset_reminder
  alias synchronize_by_preset_schedule initialize_by_preset_schedule
  alias synchronize_by_preset_todo initialize_by_preset_todo
  alias synchronize_by_preset_bookmark initialize_by_preset_bookmark
  alias synchronize_by_preset_board initialize_by_preset_board
  alias synchronize_by_preset_faq initialize_by_preset_faq
  alias synchronize_by_preset_qna initialize_by_preset_qna
  alias synchronize_by_preset_circular initialize_by_preset_circular
  alias synchronize_by_preset_monitor initialize_by_preset_monitor
  alias synchronize_by_preset_share initialize_by_preset_share
  alias synchronize_by_preset_workflow initialize_by_preset_workflow
  alias synchronize_by_preset_notice initialize_by_preset_notice
  alias synchronize_by_preset_presence initialize_by_preset_presence
  alias synchronize_by_preset_survey initialize_by_preset_survey
end
