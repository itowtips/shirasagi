class Translate::Page::GenerateJob < Cms::ApplicationJob
  include Job::Cms::GeneratorFilter

  self.task_name = "translate:generate_pages"
  self.controller = Translate::Agents::Tasks::PagesController
  self.action = :generate
end
