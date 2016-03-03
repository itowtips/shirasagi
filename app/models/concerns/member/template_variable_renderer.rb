module Member
  module TemplateVariableRenderer
    extend ActiveSupport::Concern

    module ClassMethods
      def template_variable_handlers
        instance_variable_get(:@_template_variable_handlers) || []
      end

      def template_variable_handlers=(value)
        instance_variable_set(:@_template_variable_handlers, value)
      end

      def template_variable_handler(name, proc, &block)
        handlers = template_variable_handlers

        name = name.to_sym if name.respond_to?(:to_sym)
        handlers << [name, proc || block]
        self.template_variable_handlers = handlers
      end

      def render(*args)
        options = {}
        if args.last.is_a?(Hash)
          *args, options = args
        end

        new(options).render(*args)
      end
    end

    def render(*args)
      template.gsub(/\#\{(.*?)\}/) do |m|
        str = template_variable_get($1, *args)
        str == false ? m : str
      end
    end

    private
      def template_variable_get(*args)
        name = args.first
        name_sym = name.to_sym
        _, proc = self.class.template_variable_handlers.find do |n, _|
          if n.is_a?(Symbol)
            n == name_sym
          elsif n.is_a?(Regexp)
            n =~ name
          else
            n.to_s == name
          end
        end

        return false if proc.nil?

        proc = method(proc) if proc.is_a?(Symbol)
        proc.call(*args)
      rescue => e
        Rails.logger.error("#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
        false
      end
  end
end
