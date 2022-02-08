class Gws::Portal::PresetsController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter

  model Gws::Portal::Preset

  navi_view 'gws/portal/main/navi'

  private

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site }
  end

  def set_task
    @task = Gws::Task.find_or_create_by name: task_name, site_id: @cur_site.id
  end

  def task_name
    "gws:sync_presets"
  end

  public

  def sync
    raise "403" unless @model.allowed?(:edit, @cur_user, site: @cur_site)

    set_task

    if request.get?
      respond_to do |format|
        format.html { render }
        format.json { render template: "ss/tasks/index", content_type: json_content_type, locals: { item: @task } }
      end
      return
    end

    Gws::Portal::SyncPresetJob.bind(site_id: @cur_site).perform_later
    redirect_to({ action: :sync }, { notice: I18n.t("ss.notice.started_sync") })
  end

  def reset
    raise "403" unless @model.allowed?(:edit, @cur_user, site: @cur_site)

    set_task

    if request.get?
      respond_to do |format|
        format.html { render }
        format.json { render template: "ss/tasks/index", content_type: json_content_type, locals: { item: @task } }
      end
      return
    end

    Gws::Portal::SyncPresetJob.bind(site_id: @cur_site).perform_later(action: :reset)
    redirect_to({ action: :reset }, { notice: I18n.t("ss.notice.started_initialize") })
  end
end
