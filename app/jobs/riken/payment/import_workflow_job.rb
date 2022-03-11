class Riken::Payment::ImportWorkflowJob < Gws::ApplicationJob
  include Job::SS::TaskFilter

  self.task_class = Gws::Task
  self.task_name = "riken:payment_import_workflow"

  def setting
    @_setting ||= Riken::Payment::ImporterSetting.site(site).first
  end

  def perform
    task.log "#{site.name}"
    if setting.nil?
      task.log "決済システム連携が設定されていません"
      return
    end

    Retriable.retriable(on_retry: method(:on_each_retry)) do
      setting.get_access_token
    end
    workflows = Retriable.retriable(on_retry: method(:on_each_retry)) do
      setting.get_payment_workflows
    end
    workflows.each do |workflow|
      item = Riken::Payment::Workflow.new(setting, OpenStruct.new(workflow))
      if item.save_circular_post
        @task.log "#{item.id} #{I18n.t("ss.notice.saved")}"
      else
        @task.log "#{item.id} #{item.errors.full_messages.join(",")}"
      end
    end
  end

  def on_each_retry(err, try, elapsed, interval)
    @task.log "#{err.class}: '#{err.message}' - #{try} tries in #{elapsed} seconds and #{interval} seconds until the next try."
  end
end
