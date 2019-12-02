class Translate::Node::GenerateJob < Cms::ApplicationJob
  include Job::Cms::GeneratorFilter

  self.task_name = "translate:generate_nodes"
  self.controller = Translate::Agents::Tasks::NodesController
  self.action = :generate
end
