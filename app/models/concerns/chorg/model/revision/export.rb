module Chorg::Model::Revision
  module Export
    extend ActiveSupport::Concern

    included do
      cattr_accessor :changeset_class
      class_variable_set(:@@changeset_class, Chorg::Changeset)

      attr_accessor :in_revision_csv_file
      permit_params :in_revision_csv_file

      validate :validate_in_revision_csv_file, if: -> { in_revision_csv_file.present? }
      before_save :import_revision_csv_file
    end

    def changesets_to_csv
      CSV.generate do |data|
        data << %w(
          id type source destination order
          contact_tel contact_fax contact_email contact_link_url contact_link_name
          ldap_dn
        ).map { |k| I18n.t("chorg.import.changeset.#{k}") }

        type_order = changeset_class::TYPES.each_with_index.map { |type, i| [type, i] }.to_h
        export_sets = changesets.sort do |a, b|
          order = type_order[a.type] <=> type_order[b.type]
          (order == 0) ? (a.id <=> b.id ) : order
        end
        export_sets.each do |item|
          case item.type
          when changeset_class::TYPE_UNIFY

            # N sources, 1 destination
            destination = item.destinations.to_a.first || {}
            item.sources.to_a.each do |source|
              data << changeset_csv_line(item, source, destination)
            end
          when changeset_class::TYPE_DIVISION

            # 1 source, N destinations
            source = item.sources.to_a.first || {}
            item.destinations.to_a.each do |destination|
              data << changeset_csv_line(item, source, destination)
            end
          else

            # 1 source, 1 destination
            source = item.sources.to_a.first || {}
            destination = item.destinations.to_a.first || {}
            data << changeset_csv_line(item, source, destination)
          end
        end
      end
    end

    private

    def changeset_csv_line(changeset, source, destination)
      line = []
      line << changeset.id
      line << I18n.t("chorg.options.changeset_type.#{changeset.type}")
      line << source["name"]
      line << destination["name"]
      line << destination["order"]
      line << destination["contact_tel"]
      line << destination["contact_fax"]
      line << destination["contact_email"]
      line << destination["contact_link_url"]
      line << destination["contact_link_name"]
      line << destination["ldap_dn"]
      line
    end

    def validate_in_revision_csv_file
      @add_sets = []
      @move_sets = []
      @unify_sets = {}
      @division_sets = {}
      @delete_sets = []

      type_labels = I18n.t("chorg.options.changeset_type").map { |k, v| [v, k] }.to_h

      begin
        if ::File.extname(in_revision_csv_file.original_filename) != ".csv"
          raise I18n.t("errors.messages.invalid_csv")
        end
        table = CSV.read(in_revision_csv_file.path, headers: true, encoding: 'SJIS:UTF-8')
      rescue => e
        errors.add :base, e.to_s
        return
      end

      table.each_with_index do |row, idx|
        id = row[I18n.t("chorg.import.changeset.id")].to_s.strip.to_i
        type = type_labels[row[I18n.t("chorg.import.changeset.type")]].to_s.strip
        source = {
          "name" => row[I18n.t("chorg.import.changeset.source")].to_s.strip
        }
        destination = {
          "name" => row[I18n.t("chorg.import.changeset.destination")].to_s.strip,
          "order" => row[I18n.t("chorg.import.changeset.order")].to_s.strip,
          "contact_tel" => row[I18n.t("chorg.import.changeset.contact_tel")].to_s.strip,
          "contact_fax" => row[I18n.t("chorg.import.changeset.contact_fax")].to_s.strip,
          "contact_email" => row[I18n.t("chorg.import.changeset.contact_email")].to_s.strip,
          "contact_link_url" => row[I18n.t("chorg.import.changeset.contact_link_url")].to_s.strip,
          "contact_link_name" => row[I18n.t("chorg.import.changeset.contact_link_name")].to_s.strip,
          "ldap_dn" => row[I18n.t("chorg.import.changeset.ldap_dn")].to_s.strip,
        }
        if source["name"].present?
          group = SS::Group.where(name: source["name"]).first
          source["id"] = group.id if group
        end

        case type
        when changeset_class::TYPE_ADD

          changeset = changeset_class.new
          changeset.type = type
          changeset.cur_revision = self
          changeset.destinations = [destination]
          @add_sets << [changeset, idx + 2]

        when changeset_class::TYPE_MOVE

          changeset = changeset_class.new
          changeset.type = type
          changeset.cur_revision = self
          changeset.sources = [source]
          changeset.destinations = [destination]
          @move_sets << [changeset, idx + 2]

        when changeset_class::TYPE_UNIFY

          key = [id, destination["name"]]
          if @unify_sets[key]
            changeset, _idx = @unify_sets[key]
            changeset.sources << source
            @unify_sets[key] = [changeset, _idx + [idx + 2]]
          else
            changeset= changeset_class.new
            changeset.type = type
            changeset.cur_revision = self
            changeset.sources = [source]
            changeset.destinations = [destination]
            @unify_sets[key] = [changeset, [idx + 2]]
          end

        when changeset_class::TYPE_DIVISION

          key = [id, source["name"]]
          if @division_sets[key]
            changeset, _idx = @division_sets[key]
            changeset.destinations << destination
            @division_sets[key] = [changeset, _idx + [idx + 2]]
          else
            changeset = changeset_class.new
            changeset.type = type
            changeset.cur_revision = self
            changeset.sources = [source]
            changeset.destinations = [destination]
            @division_sets[key] = [changeset, [idx + 2]]
          end

        when changeset_class::TYPE_DELETE

          changeset = changeset_class.new
          changeset.type = type
          changeset.cur_revision = self
          changeset.sources = [source]
          @delete_sets << [changeset, idx + 2]

        end
      end

      @add_sets.each do |changeset, idx|
        next if changeset.valid?
        changeset.errors.full_messages.each do |e|
          errors.add :base, "#{idx} : #{e}"
        end
      end
      @move_sets.each do |changeset, idx|
        next if changeset.valid?
        changeset.errors.full_messages.each do |e|
          errors.add :base, "#{idx} : #{e}"
        end
      end
      @unify_sets.each do |key, changesets|
        changeset, idx = changesets
        next if changeset.valid?
        changeset.errors.full_messages.each do |e|
          errors.add :base, "#{idx.join(",")} : #{e}"
        end
      end
      @division_sets.each do |key, changesets|
        changeset, idx = changesets
        next if changeset.valid?
        changeset.errors.full_messages.each do |e|
          errors.add :base, "#{idx.join(",")} : #{e}"
        end
      end
      @delete_sets.each do |changeset, idx|
        next if changeset.valid?
        changeset.errors.full_messages.each do |e|
          errors.add :base, "#{idx} : #{e}"
        end
      end
    end

    def import_revision_csv_file
      return if in_revision_csv_file.blank?
      changesets.destroy_all

      if @add_sets
        @add_sets.each do |changeset, idx|
          changeset.revision_id = self.id
          changeset.save!
        end
      end

      if @move_sets
        @move_sets.each do |changeset, idx|
          changeset.revision_id = self.id
          changeset.save!
        end
      end

      if @unify_sets
        @unify_sets.each do |key, changesets|
          changeset, idx = changesets
          changeset.revision_id = self.id
          changeset.save!
        end
      end

      if @division_sets
        @division_sets.each do |key, changesets|
          changeset, idx = changesets
          changeset.revision_id = self.id
          changeset.save!
        end
      end

      if @delete_sets
        @delete_sets.each do |changeset, idx|
          changeset.revision_id = self.id
          changeset.save!
        end
      end
    end
  end
end
