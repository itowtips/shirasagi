module DesignBook::Addon
  module DesignBookNumber
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :design_book_number, type: String
      permit_params :design_book_number
      validates :design_book_number, uniqueness: { scope: :site_id }, length: { is: 10, allow_blank: true },
                numericality: { only_integer: true, allow_blank: true }

      if respond_to? :template_variable_handler
        template_variable_handler :design_book_number, :template_variable_handler_name
      end
      if respond_to? :liquidize
        liquidize do
          export :design_book_number
        end
      end
    end

    def set_filename
      self.basename = design_book_number
      super
    end
  end
end
