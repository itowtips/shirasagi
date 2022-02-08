module Riken::Ldap

  RkUser = Struct.new(
    :dn, :rk_uid, :uid, :cn_jp, :gn_jp, :mn_jp, :cn_furigana, :gn_furigana, :mn_furigana,
    :cn, :gn, :mn_en, :main_superior_id, :mail, :ict6k_flg,
    :lab_dn, :belongs_to, keyword_init: true
  )

  RkOrganization = Struct.new(:dn, :cn_j, :cn, :hierarchy_lab_name_j, :hierarchy_lab_name_e, keyword_init: true)

  class CsvSearcher
    def initialize(user_csv_file, group_csv_file)
      @user_csv_file = user_csv_file
      @group_csv_file = group_csv_file
    end

    def each_user
      SS::Csv.foreach_row(@user_csv_file) do |row|
        user = RkUser.new(RkUser.members.index_with { |m| row[m.to_s] })
        user.lab_dn = user.lab_dn.split(/\R/)
        user.belongs_to = user.belongs_to.split(/\R/)

        yield user
      end
    end

    def each_group
      SS::Csv.foreach_row(@group_csv_file) do |row|
        yield RkOrganization.new(RkOrganization.members.index_with { |m| row[m.to_s] })
      end
    end
  end
end
