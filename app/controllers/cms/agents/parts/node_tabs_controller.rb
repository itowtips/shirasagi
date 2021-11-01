class Cms::Agents::Parts::NodeTabsController < ApplicationController
  include Cms::PartFilter::View
  include Cms::PublicFilter::Agent
  helper Cms::TabsHelper

  def index
    @tabs = []
    # save_site = @cur_site
    # save_node = @cur_node

    @cur_part.interpret_conditions(site: @cur_site, default_location: :never, request_dir: false) do |site, content_or_path|
      if content_or_path.is_a?(Cms::Content) || content_or_path == :root_contents || content_or_path.end_with?("*")
        # - default content is not supported
        # - root content is not supported
        # - wildcard is not supported
        next
      end

      node = Cms::Node.site(site).and_public.filename(content_or_path).first
      next unless node

      @tabs << tab = { name: node.name, url: node.url, rss: nil, nodes: [] }

      rest = content_or_path.sub(/^#{::Regexp.escape(node.filename)}/, "")
      spec = recognize_agent "/.s#{site.id}/nodes/#{node.route}#{rest}", method: "GET"
      next unless spec

      node_class = node.route.sub(/\/.*/, "/agents/#{spec[:cell]}")
      set_agent(node_class)

      nodes = nil

      # if @agent.controller.class.method_defined?(:index)
      #   begin
      #     @cur_site = site
      #     @cur_node = node
      #     nodes = call_node_index
      #   ensure
      #     @cur_site = save_site
      #     @cur_node = save_node
      #   end
      # end

      if nodes.nil?
        if node.class.method_defined?(:condition_hash)
          nodes = Cms::Node.public_list(site: site, node: node, date: @cur_date)
        else
          nodes = Cms::Node.site(site).and_public(@cur_date).node(node)
        end
      end

      nodes = nodes ? nodes.order_by(node.try(:sort_hash).presence || { released: -1 }).limit(@cur_part.limit) : []
      tab[:nodes] = nodes.to_a
      tab[:rss]   = "#{node.url}rss.xml" if @agent.controller.class.method_defined?(:rss)
    end

    render
  end

  private

  def set_agent(node_class)
    @agent = new_agent(node_class)
    @agent.controller.params = {}
    @agent.controller.extend(SS::ImplicitRenderFilter)
  end

  def call_node_index
    nodes = nil

    begin
      @agent.invoke :index
      nodes = @agent.instance_variable_get(:@items)
      nodes = nil if nodes && !nodes.respond_to?(:current_page)
      nodes = nil if nodes && !nodes.klass.include?(Cms::Model::Node)
    rescue => e
      logger.error $ERROR_INFO
      logger.error $ERROR_INFO.backtrace.join("\n")
    end

    nodes
  end
end
