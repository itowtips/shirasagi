class Riken::Ldap::ImportJob < Gws::ApplicationJob
  include Job::SS::TaskFilter

  self.task_class = Gws::Task
  self.task_name = "riken:ldap_import"

  def perform(opts = {})
    @now = Time.zone.now
    @group_success_count = 0
    @group_error_count = 0
    @user_success_count = 0
    @user_error_count = 0
    @imported_groups = []

    # warm-up slack-id map
    slack_id_map

    synchronize_all_groups
    synchronize_all_users

    task.log "ldap インポートを実行しました。"
    task.log "グループ成功件数: #{@group_success_count}, グループ失敗件数: #{@group_error_count}"
    task.log "ユーザー成功件数: #{@user_success_count}, ユーザー失敗件数: #{@user_error_count}"
  rescue => e
    Rails.logger.fatal { "#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}" }
    raise
  end

  private

  def task_cond
    { name: self.class.task_name, group_id: site.id }
  end

  def ldap_searcher
    @ldap_searcher ||= begin
      raise NotImplementedError
    end
  end

  def synchronize_all_groups
    base_criteria = Gws::Group.all.unscoped.site(site)

    ldap_searcher.each_group do |ldap_group|
      Rails.logger.tagged(ldap_group.dn) do
        group = synchronize_one_group(base_criteria, ldap_group)
        @imported_groups << group
        @group_success_count += 1
      rescue => e
        @group_error_count += 1
        Rails.logger.error { "#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}" }
      end
    end

    return if @group_error_count > 0 || @user_error_count > 0

    unimported_group_ids = base_criteria.pluck(:id) - @imported_groups.map(&:id)
    return if unimported_group_ids.blank?

    base_criteria.in(id: unimported_group_ids).set(expiration_date: @now.change(sec: 0).utc)
  end

  def synchronize_one_group(base_criteria, ldap_group)
    group = base_criteria.where(ldap_dn: ldap_group.dn).first
    group ||= Gws::Group.new(ldap_dn: ldap_group.dn)

    group.i18n_name_translations = {
      ja: normalize_and_join(ldap_group.hierarchy_lab_name_j, ldap_group.cn_j, separator: "/"),
      en: normalize_and_join(ldap_group.hierarchy_lab_name_e, ldap_group.cn, separator: "/")
    }
    group.save!
    group
  end

  def synchronize_all_users
    base_criteria = Gws::User.all.unscoped.site(site)

    imported_users = {}
    pending_superiors = []
    ldap_searcher.each_user do |ldap_user|
      Rails.logger.tagged(ldap_user.rk_uid) do
        user = synchronize_one_user(base_criteria, ldap_user)
        imported_users[ldap_user.rk_uid] = user
        main_superior_id = normalize(ldap_user.main_superior_id)
        if main_superior_id
          pending_superiors << [ ldap_user.rk_uid, main_superior_id ]
        end
        @user_success_count += 1
      rescue => e
        @user_error_count += 1
        Rails.logger.error { "#{e.class} (#{e.message}):\n  #{e.backtrace.join("\n  ")}" }
      end
    end

    pending_superiors.each do |rk_uid, main_superior_id|
      Rails.logger.tagged(rk_uid) do
        superior_user = imported_users[main_superior_id]
        if superior_user.blank?
          Rails.logger.warn { "superior '#{main_superior_id}' is not found" }
          next
        end

        user = imported_users[rk_uid]
        user.update(superior: superior_user)
      end
    end

    return if @group_error_count > 0 || @user_error_count > 0

    unimported_user_ids = base_criteria.pluck(:id) - imported_users.values.map(&:id)
    base_criteria.in(id: unimported_user_ids).set(account_expiration_date: @now.change(sec: 0).utc)
  end

  def synchronize_one_user(base_criteria, ldap_user)
    encrypted_rk_uid = Riken.encrypt(ldap_user.rk_uid)
    user = base_criteria.where(uid: encrypted_rk_uid).first
    user ||= Gws::User.new(uid: encrypted_rk_uid)

    user.i18n_name_translations = {
      ja: normalize_and_join(ldap_user.cn_jp, ldap_user.gn_jp, ldap_user.mn_jp),
      en: normalize_and_join(ldap_user.cn, ldap_user.gn, ldap_user.mn_en)
    }
    user.kana = normalize_and_join(ldap_user.cn_furigana, ldap_user.gn_furigana, ldap_user.mn_furigana)
    user.email = normalize(ldap_user.mail)
    user.type = SS::User::TYPE_SSO
    user.login_roles = [ SS::User::LOGIN_ROLE_SSO ]
    user.organization = site
    user.group_ids = resolve_groups(ldap_user)
    user.in_gws_main_group_id = resolve_main_group(ldap_user)
    user.send_notice_slack_id = resolve_slack_id(ldap_user)

    user.save!
    user
  end

  def normalize(value)
    return if value.blank?

    value = value.strip
    return if value == "-"

    value
  end

  def normalize_and_join(*args, separator: " ")
    args.map { |arg| normalize(arg) }.compact.join(separator)
  end

  def resolve_groups(ldap_user)
    groups = select_groups_by_dn(ldap_user.lab_dn)
    groups += select_groups_by_dn(ldap_user.belongs_to)
    groups.compact!
    groups.uniq!
    groups.map(&:id)
  end

  def resolve_main_group(ldap_user)
    groups = select_groups_by_dn(ldap_user.lab_dn)
    groups.compact!
    groups.uniq!
    groups.first.try(:id)
  end

  def slack_id_map
    return @slack_id_map if @slack_id_map

    if site.slack_oauth_token.blank?
      Rails.logger.info { "slack_oauth_token is not set" }

      @slack_id_map = {}
      return @slack_id_map
    end

    client = site.slack_client
    test_result = client.auth_test
    if test_result.blank? || !test_result[:ok]
      Rails.logger.warn { "auth.test is failed" }

      @slack_id_map = {}
      return @slack_id_map
    end

    map = {}
    client.users_list do |page|
      next if !page[:ok]

      page[:members].map do |member|
        next if member["deleted"]

        profile = member["profile"]
        next if profile.blank?

        email = profile["email"]
        next if email.blank?

        if map.key?(email)
          Rails.logger.warn { "#{email} is mapped to 2+ slack accounts" }
          next
        end

        map[email] = member[:id]
      end
    end

    @slack_id_map = map
  end

  def resolve_slack_id(ldap_user)
    mail = normalize(ldap_user.mail)
    return if mail.blank?

    slack_id_map[ldap_user.mail]
  end

  def select_groups_by_dn(dns)
    dns.map do |dn|
      dn = normalize(dn)
      next if dn.blank?

      group = find_group_by_dn(dn)
      Rails.logger.warn("group dn #{dn} is not found") if group.blank?
      group
    end
  end

  def find_group_by_dn(dn)
    @imported_groups.find { |group| group.ldap_dn == dn }
  end
end
