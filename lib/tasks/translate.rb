module Tasks
  module Translate
    class << self
      def generate_nodes
        each_sites do |site|
          if ENV.key?("node")
            with_node(site, ENV["node"]) do |node|
              perform_job(::Transalte::Node::GenerateJob, site: site, node: node)
            end
          else
            perform_job(::Translate::Node::GenerateJob, site: site)
          end
        end
      end

      def generate_pages
        each_sites do |site|
          if ENV.key?("node")
            with_node(site, ENV["node"]) do |node|
              perform_job(::Transalte::Page::GenerateJob, site: site, node: node)
            end
          else
            perform_job(::Translate::Page::GenerateJob, site: site)
          end
        end
      end

      def each_sites
        name = ENV['site']
        if name
          all_ids = ::Cms::Site.where(host: name).pluck(:id)
        else
          all_ids = ::Cms::Site.all.pluck(:id)
        end

        all_ids.each_slice(20) do |ids|
          ::Cms::Site.where(:id.in => ids).each do |site|
            yield site
          end
        end
      end

      def perform_job(job_class, opts = {})
        job = job_class.bind(site_id: opts.delete(:site))
        job = job.bind(node_id: opts.delete(:node)) if opts.key?(:node)
        job.perform_now(opts)
      end
    end
  end
end
