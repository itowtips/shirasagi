module Cms::Translation
  extend ActiveSupport::Concern
  include SS::TemplateVariable

  def translatable?
    true
  end
end
