require "csv"

module Gws::Addon::Import
  module Group
    extend ActiveSupport::Concern
    extend SS::Addon

    CSV_HEADERS = begin
      headers = %w(id)
      headers << "i18n_name_translations.#{I18n.default_locale}"
      I18n.available_locales.reject { |lang| lang == I18n.default_locale }.each do |lang|
        headers << "i18n_name_translations.#{lang}"
      end
      headers += %w(domains order ldap_dn activation_date expiration_date)
      headers
    end.freeze

    included do
      attr_accessor :in_file, :imported

      permit_params :in_file
    end

    module ClassMethods
      def csv_headers
        CSV_HEADERS
      end

      def to_csv
        CSV.generate do |data|
          data << csv_headers.map { |k| t k }
          criteria.each do |item|
            line = []
            line << item.id
            line << item.i18n_name_translations[I18n.default_locale]
            I18n.available_locales.reject { |lang| lang == I18n.default_locale }.each do |lang|
              line << item.i18n_name_translations[lang]
            end
            line << item.domains
            line << item.order
            line << item.ldap_dn
            line << (item.activation_date.present? ? I18n.l(item.activation_date) : nil)
            line << (item.expiration_date.present? ? I18n.l(item.expiration_date) : nil)
            data << line
          end
        end
      end
    end

    def import
      @imported = 0
      validate_import
      return false unless errors.empty?

      SS::Csv.foreach_row(in_file, headers: true) do |row, i|
        update_row(row, i + 2)
      end
      return errors.empty?
    end

    private

    def validate_import
      return errors.add :in_file, :blank if in_file.blank?
      return errors.add :cur_site, :blank if cur_site.blank?

      fname = in_file.original_filename
      unless /^\.csv$/i.match?(::File.extname(fname))
        errors.add :in_file, :invalid_file_type
        return
      end

      errors.add :in_file, :invalid_file_type if !SS::Csv.valid_csv?(in_file, headers: true)
      in_file.rewind
    end

    def get_value(row, key)
      column_name = t(key)
      return row[column_name] if row.key?(column_name)

      I18n.available_locales.reject { |lang| lang == I18n.locale }.each do |lang|
        column_name = t(key, locale: lang)
        next if column_name.blank?

        return row[column_name] if row.key?(column_name)
      end

      nil
    end

    def update_row(row, index)
      id              = get_value(row, "id").to_s.strip
      name            = get_value(row, "name").to_s.strip
      domains         = get_value(row, "domains").to_s.strip
      order           = get_value(row, "order").to_s.strip
      ldap_dn         = get_value(row, "ldap_dn").to_s.strip
      activation_date = get_value(row, "activation_date").to_s.strip
      expiration_date = get_value(row, "expiration_date").to_s.strip

      i18n_name_translations = {}
      I18n.available_locales.each do |lang|
        i18n_name = get_value(row, "i18n_name_translations.#{lang}")
        if i18n_name.present?
          i18n_name_translations[lang] = i18n_name
        end
      end
      name = i18n_name_translations[I18n.default_locale] if name.blank?

      if id.present?
        item = self.class.unscoped.site(cur_site).where(id: id).first
        if item.blank?
          self.errors.add :base, :not_found, line_no: index, id: id
          return nil
        end

        if name.blank?
          item.disable
          @imported += 1
          return nil
        end
      else
        item = self.class.new
      end

      item.name = name
      item.i18n_name_translations = i18n_name_translations if i18n_name_translations.present?
      item.order = order
      item.domains = domains
      item.ldap_dn = ldap_dn
      item.activation_date = activation_date
      item.expiration_date = expiration_date

      if item.save
        @imported += 1
      else
        set_errors(item, index)
      end
      item
    end

    def set_errors(item, index)
      SS::Model.copy_errors(item, self, prefix: "#{index}: ")
    end
  end
end
