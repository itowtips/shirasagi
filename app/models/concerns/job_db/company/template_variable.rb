module JobDb::Company::TemplateVariable
  extend ActiveSupport::Concern
  include SS::TemplateVariable

  included do
    template_variable_handler(:name, :template_variable_handler_name)
    template_variable_handler(:index_name, :template_variable_handler_name)
    template_variable_handler(:class, :template_variable_handler_class)
    template_variable_handler(:new, :template_variable_handler_new)
    template_variable_handler(:date, :template_variable_handler_date)
    template_variable_handler('date.default') { |name, issuer| template_variable_handler_date(name, issuer, :default) }
    template_variable_handler('date.iso') { |name, issuer| template_variable_handler_date(name, issuer, :iso) }
    template_variable_handler('date.long') { |name, issuer| template_variable_handler_date(name, issuer, :long) }
    template_variable_handler('date.short') { |name, issuer| template_variable_handler_date(name, issuer, :short) }
    template_variable_handler(:current, :template_variable_handler_current)
  end

  private
    def template_variable_handler_name(name, issuer)
      ERB::Util.html_escape self.name
    end

    def template_variable_handler_class(name, issuer)
      self.filename.sub(/\..*/, "").dasherize
    end

    def template_variable_handler_new(name, issuer)
      issuer.respond_to?(:in_new_days?) && issuer.in_new_days?(self.date) ? "new" : nil
    end

    def template_variable_handler_date(name, issuer, format = nil)
      if format.nil?
        I18n.l self.date.to_date
      else
        I18n.l self.date.to_date, format: format.to_sym
      end
    end

    def template_variable_handler_current(name, issuer)
      false
    end
end
