module SS::TemplateVariable
  extend ActiveSupport::Concern
  extend SS::Translation

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
  end

  def template_variable_get(item, name)
    name_sym = name.to_sym
    _, proc = self.class.template_variable_handlers.find do |n, _|
      if n.is_a?(Symbol)
        n == name_sym
      elsif n.is_a?(Regexp)
        n =~ name
      else
        false
      end
    end

    return false if proc.nil?

    proc = method(proc) if proc.is_a?(Symbol)
    proc.call(item, name)
  end
end
