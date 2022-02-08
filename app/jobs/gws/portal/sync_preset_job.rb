class Gws::Portal::SyncPresetJob < Gws::ApplicationJob
  include Job::Gws::TaskFilter

  self.task_name = "gws:sync_presets"
  self.controller = Gws::Agents::Tasks::Portal::PresetController
  self.action = :sync

  def perform(opts = {})
    action = self.class.action
    action = opts[:action] if opts[:action]
    task.process self.class.controller, action, { site: site, user: user }
  end

  def task_cond
    cond = { name: self.class.task_name }
    cond[:site_id] = site_id
    cond
  end
end
