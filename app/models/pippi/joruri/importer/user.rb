module Pippi::Joruri::Importer
  class User < Base
    def initialize(site)
      super(site)
    end

    def import_groups
      groups = []

      path = ::File.join(csv_path, "groups.csv")
      csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      csv.each_with_index do |row, idx|
        next if row["name"].blank?

        name = row["name"].to_s.squish
        tel = row["tel"].to_s.squish
        email = row["email"].to_s.squish
        order = row["order"]
        puts "#{idx}.#{name}"

        group = Cms::Group.find_or_initialize_by(name: name)
        group.contact_tel = tel if tel.present?
        group.contact_email = email if email.present?
        group.order = order
        group.save!
        groups << group
      end

      site.group_ids = (site.group_ids.to_a + groups.select { |group| group.depth == 0 }.map(&:id)).uniq
      site.save

      SS::Group.where(name: /^シラサギ市/).each do |group|
        group.order = 9999
        group.save
      end
    end

    def import_users
      groups = {}
      roles = {
        5 => Cms::Role.site(site).where(name: "管理者").to_a,
        2 => Cms::Role.site(site).where(name: "編集者").to_a
      }

      path = ::File.join(csv_path, "groups.csv")
      csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      csv.each_with_index do |row, idx|
        next if row["code"].blank?
        code = row["code"].to_i
        name = row["name"].to_s.squish
        groups[code] = Cms::Group.find_by(name: name)
      end

      path = ::File.join(csv_path, "users.csv")
      csv = ::CSV.read(path, headers: true, encoding: 'BOM|UTF-8')
      csv.each_with_index do |row, idx|
        next if row["account"].blank?

        account = row["account"].to_s.squish
        name = row["name"].to_s.squish
        email = row["email"].to_s.squish
        password = row["password"].to_s.squish
        code = row["group_code"].to_i
        auth_no = row["auth_no"].to_i
        puts "#{idx}.#{name}"

        user = Cms::User.find_or_initialize_by(uid: account)
        user.name = name
        user.uid = account
        user.email = email if email.present?
        user.in_password = password
        user.group_ids = [groups[code].id]
        user.cms_role_ids = roles[auth_no].map(&:id)
        user.save!
      end
    end
  end
end
