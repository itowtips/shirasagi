module SS::Fields::DependantI18nNaming
  extend ActiveSupport::Concern

  included do
    cattr_accessor(:name_field, instance_accessor: false) { "name" }
    attr_accessor :skip_rename_children

    after_save :rename_children, if: ->{ @db_changes && !skip_rename_children }
  end

  def trailing_name
    send(self.class.name_field).split("/").pop
  end

  def depth
    send(self.class.name_field).scan("/").size + 1
  end

  def self.rename_i18n_name(current_translations, src_translations, dst_translations)
    ret = current_translations.dup

    I18n.available_locales.each do |lang|
      src = src_translations[lang]
      dst = dst_translations[lang]
      next if src.blank? || dst.blank?

      val = current_translations[lang]
      next if val.blank?

      ret[lang] = val.sub(/^#{::Regexp.escape(src)}\//, "#{dst}/")
    end

    ret
  end

  private

  def dependant_scope
    self.class.all
  end

  def rename_children
    src_name, dst_name = @db_changes[self.class.name_field]
    src_translations, dst_translations = @db_changes["i18n_#{self.class.name_field}"]
    changes = (src_name.present? && dst_name.present?) || (src_translations.present? && dst_translations.present?)
    return unless changes

    old_name = src_name || send("#{self.class.name_field}_was")
    criteria = dependant_scope.ne(id: id)
    criteria = criteria.where(self.class.name_field => /^#{::Regexp.escape(old_name)}\//)
    criteria.to_a.each do |item|
      if src_name.present? && dst_name.present?
        changed_val = item.send(self.class.name_field)
        changed_val = changed_val.sub(/^#{::Regexp.escape(src_name)}\//, "#{dst_name}/")
        item.send("#{self.class.name_field}=", changed_val)
      end

      if src_translations.present? && dst_translations.present?
        translations = item.send("i18n_#{self.class.name_field}_translations")
        translations = SS::Fields::DependantI18nNaming.rename_i18n_name(translations, src_translations, dst_translations)
        item.send("i18n_#{self.class.name_field}_translations=", translations)
      end

      item.skip_rename_children = true
      item.skip_synchronize_i18n_name = true
      item.save(validate: false)
    end
  end
end
