module Tasks
  module Riken
    class Payment
      extend Tasks::Gws::Base

      class << self
        def import_workflows
          each_sites do |site|
            ::Riken::Payment::ImportWorkflowJob.bind(site_id: site.id).perform_now
          end
        end
      end
    end
  end
end
