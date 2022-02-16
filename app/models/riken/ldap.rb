module Riken::Ldap

  RkUser = Struct.new(
    :dn, :rk_uid, :uid, :main_lab_cd, :cn_jp, :gn_jp, :mn_jp, :cn_furigana, :gn_furigana, :mn_furigana,
    :cn, :gn, :mn_en, :main_superior_id, :mail, :ict6k_flg,
    :lab_dn, :belongs_to, keyword_init: true
  )

  RK_USER_ARRAY_ATTRS = %i[lab_dn belongs_to].freeze

  RkOrganization = Struct.new(:dn, :superior_id, :cn_j, :cn, :hierarchy_lab_name_j, :hierarchy_lab_name_e, keyword_init: true)

  DEFAULT_USER_DN = "ou=users,o=riken,c=jp".freeze
  DEFAULT_USER_FILTER = "(&(retiredFlg=0)(!(rkUid=XTS*)))".freeze

  DEFAULT_GROUP_DN = "ou=organizations,o=riken,c=jp".freeze
  DEFAULT_GROUP_FILTER = "(&(deletedFlg=0)(!(labCd=0*)))".freeze

  Searcher = Struct.new(:cur_site, keyword_init: true) do
    def user_dn
      cur_site.riken_ldap_user_dn.presence || DEFAULT_USER_DN
    end

    def user_filter
      cur_site.riken_ldap_user_filter.presence || DEFAULT_USER_FILTER
    end

    def group_dn
      cur_site.riken_ldap_group_dn.presence || DEFAULT_GROUP_DN
    end

    def group_filter
      cur_site.riken_ldap_group_filter.presence || DEFAULT_GROUP_FILTER
    end

    def each_user_with_filter(base_dn, filter)
      connection = cur_site.riken_ldap_connection!
      filter = Net::LDAP::Filter.construct(filter)
      result = Retriable.retriable(on_retry: method(:on_each_retry)) do
        connection.search(base: base_dn, filter: filter)
      end
      return if result.blank?

      result.each do |entry|
        attrs = RkUser.members.index_with do |m|
          values = entry[m.to_s.delete("_")]

          if RK_USER_ARRAY_ATTRS.include?(m)
            values.map(&:to_s)
          else
            values.first.to_s
          end
        end

        yield RkUser.new(attrs)
      end
    end

    def each_user(&block)
      each_user_with_filter(user_dn, user_filter, &block)
    end

    def each_group
      connection = cur_site.riken_ldap_connection!
      filter = Net::LDAP::Filter.construct(group_filter)
      result = Retriable.retriable(on_retry: method(:on_each_retry)) do
        connection.search(base: group_dn, filter: filter)
      end
      return if result.blank?

      result.each do |entry|
        attrs = RkOrganization.members.index_with do |m|
          values = entry[m.to_s.delete("_")]
          values.first.to_s
        end

        yield RkOrganization.new(attrs)
      end
    end

    def on_each_retry(err, try, elapsed, interval)
      Rails.logger.warn do
        "#{err.class}: '#{err.message}' - #{try} tries in #{elapsed} seconds and #{interval} seconds until the next try."
      end
    end
  end
end
