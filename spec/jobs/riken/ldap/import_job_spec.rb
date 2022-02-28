require 'spec_helper'

describe Riken::Ldap::ImportJob, dbscope: :example do
  let!(:site) do
    i18n_name_translations = {
      ja: "シラサギ大学",
      en: "Shirasagi Univ"
    }
    Gws::Group.create(i18n_name_translations: i18n_name_translations, ldap_dn: "labCd=100001,OU=Organizations,O=example,C=jp")
  end
  let(:user_csv_file) { "#{Rails.root}/spec/fixtures/riken/ldap_user1.csv" }
  let(:group_csv_file) { "#{Rails.root}/spec/fixtures/riken/ldap_group1.csv" }
  let!(:sys_role1) { create :sys_role_gws, cur_user: nil, name: unique_id }
  let!(:gws_role1) { create :gws_role, :gws_role_portal_user_use, cur_site: site, cur_user: nil }
  let(:custom_group_name1) { "custom-group-#{unique_id}" }

  let(:csv_searcher1) do
    Struct.new(:user_csv_file, :group_csv_file) do
      def each_user
        SS::Csv.foreach_row(user_csv_file) do |row|
          user = Riken::Ldap::RkUser.new(Riken::Ldap::RkUser.members.index_with { |m| row[m.to_s] })
          Riken::Ldap::RK_USER_ARRAY_ATTRS.each do |field|
            user.send("#{field}=", user.send(field).split(/\R/))
          end

          yield user
        end
      end

      def each_user_with_filter(_base_dn, _filter)
        SS::Csv.foreach_row(user_csv_file) do |row|
          user = Riken::Ldap::RkUser.new(Riken::Ldap::RkUser.members.index_with { |m| row[m.to_s] })
          Riken::Ldap::RK_USER_ARRAY_ATTRS.each do |field|
            user.send("#{field}=", user.send(field).split(/\R/))
          end
          next if user.ict6k_flg != '0'

          yield user
        end
      end

      def each_group
        SS::Csv.foreach_row(group_csv_file) do |row|
          yield Riken::Ldap::RkOrganization.new(Riken::Ldap::RkOrganization.members.index_with { |m| row[m.to_s] })
        end
      end
    end
  end
  let(:csv_searcher2_raise_on_group) do
    Class.new(csv_searcher1) do
      def each_group
        raise Timeout::Error
      end
    end
  end
  let(:csv_searcher3_raise_on_user) do
    Class.new(csv_searcher1) do
      def each_user
        raise Timeout::Error
      end
    end
  end
  let(:csv_searcher4_empties) do
    Struct.new(:user_csv_file, :group_csv_file) do
      def each_user
      end

      def each_group
      end
    end
  end

  before do
    @net_connect_allowed = WebMock.net_connect_allowed?
    WebMock.disable_net_connect!

    stub_request(:post, "https://slack.com/api/auth.test").
      to_return(status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/riken/auth_test1.json"), headers: {})
    stub_request(:post, "https://slack.com/api/users.list").
      to_return(status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/riken/users_list1.json"), headers: {})

    ldap_double = double(Net::LDAP)
    allow(Net::LDAP).to receive(:new).and_return(ldap_double)
    allow(ldap_double).to receive(:bind).and_return(true)

    site.slack_oauth_token = unique_id

    site.riken_ldap_url = "ldaps://example.jp/"
    site.riken_ldap_bind_dn = "cn=admin,o=example,c=jp"
    site.riken_ldap_bind_password = Riken.encrypt(unique_id)
    site.riken_ldap_group_dn = "ou=organizations,o=example,c=jp"
    site.riken_ldap_group_filter = "(deletedFlg=0)"
    site.riken_ldap_user_dn = "ou=users,o=example,c=jp"
    site.riken_ldap_user_filter = "(deletedFlg=0)"
    site.riken_ldap_sys_role_ids = [ "", sys_role1.id ]
    site.riken_ldap_gws_role_ids = [ "", gws_role1.id ]
    site.riken_ldap_custom_group_conditions = [
      { name: custom_group_name1, dn: "ou=users,o=example,c=jp", filter: "(ict6kflg=0)" }
    ]

    site.save!
  end

  after do
    WebMock.reset!
    WebMock.allow_net_connect! if @net_connect_allowed
  end

  context "想定されるケース: 繰り返し取り込んでみる（といってもテストでは2回）" do
    it do
      #
      # 1st attempts
      #
      job = Riken::Ldap::ImportJob.new.bind("site_id" => site.id)
      job.instance_variable_set(:@ldap_searcher, csv_searcher1.new(user_csv_file, group_csv_file))
      expect { job.perform_now }.to \
        output(include("グループ失敗件数: 0", "ユーザー失敗件数: 0", "カスタムグループ失敗件数: 0", "ldap インポートを実行しました。")).to_stdout

      expect(Job::Log.count).to eq 1
      Job::Log.first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)

        expect(log.logs).to include(/INFO -- : .* グループ成功件数: 6, グループ失敗件数: 0/)
        expect(log.logs).to include(/INFO -- : .* ユーザー成功件数: 7, ユーザー失敗件数: 0/)
        expect(log.logs).to include(/INFO -- : .* カスタムグループ成功件数: 1, カスタムグループ失敗件数: 0/)
      end

      expect(Gws::Group.all.count).to eq 7
      expect(Gws::Group.all.active.count).to eq 7
      expect(Gws::User.all.count).to eq 7
      expect(Gws::User.all.active.count).to eq 7
      expect(Gws::User.all.and_enabled.count).to eq 7
      expect(Gws::CustomGroup.all.count).to eq 1

      Gws::Group.all.site(site).find_by(ldap_dn: "labCd=111001,OU=Organizations,O=example,C=jp").tap do |group|
        expect(group.i18n_name_translations[:ja]).to eq "シラサギ大学/企画政策部/政策課"
        expect(group.i18n_name_translations[:en]).to eq "Shirasagi Univ/Kikaku Seisaku Department/Seisaku Section"
        expect(group.superior.try(:email)).to eq "admin@example.jp"
      end
      Gws::Group.all.site(site).find_by(ldap_dn: "labCd=112001,OU=Organizations,O=example,C=jp").tap do |group|
        expect(group.i18n_name_translations[:ja]).to eq "シラサギ大学/危機管理部/管理課"
        expect(group.i18n_name_translations[:en]).to eq "Shirasagi Univ/Kiki Kanri Department/Kanri Section"
        expect(group.superior.try(:email)).to eq "user4@example.jp"
      end

      Gws::User.all.site(site).find_by(uid: Riken.encrypt("1001")).tap do |user|
        user.cur_site = site

        expect(user.i18n_name_translations[:ja]).to eq "システム管理者"
        expect(user.i18n_name_translations[:en]).to eq "System Admin"
        expect(user.kana).to eq "システムカンリシャ"
        expect(user.email).to eq "sys@example.jp"
        expect(user.groups.count).to eq 2
        expect(user.groups.map(&:name)).to include("シラサギ大学", "シラサギ大学/企画政策部/政策課")
        expect(user.gws_main_group.name).to eq "シラサギ大学/企画政策部/政策課"
        expect(user.send_notice_slack_id).to be_blank
        expect(user.notice_circular_slack_user_setting).to eq "silence"
        expect(user.sys_role_ids).to include(sys_role1.id)
        expect(user.gws_role_ids).to include(sys_role1.id)

        expect(user.type).to eq SS::User::TYPE_SSO
        expect(user.login_roles).to include(SS::User::LOGIN_ROLE_SSO)
        expect(user.password).to be_blank
        expect(user.active?).to be_truthy
        expect(user.ldap_dn).to be_blank # ldap_dn には rkUid が含まれており、rkUid は守秘情報なので保存しないようにする
      end
      Gws::User.all.site(site).find_by(uid: Riken.encrypt("1003")).tap do |user|
        user.cur_site = site

        expect(user.i18n_name_translations[:ja]).to eq "鈴木 茂"
        expect(user.i18n_name_translations[:en]).to eq "Suzuki Shigeru"
        expect(user.kana).to eq "スズキ シゲル"
        expect(user.email).to eq "user1@example.jp"
        expect(user.groups.count).to eq 2
        expect(user.groups.map(&:name)).to include("シラサギ大学", "シラサギ大学/企画政策部/政策課")
        expect(user.gws_main_group.name).to eq "シラサギ大学/企画政策部/政策課"
        expect(user.send_notice_slack_id).to eq "47AEBBA29"
        expect(user.notice_circular_slack_user_setting).to eq "notify"
        expect(user.sys_role_ids).to include(sys_role1.id)
        expect(user.gws_role_ids).to include(sys_role1.id)

        expect(user.type).to eq SS::User::TYPE_SSO
        expect(user.login_roles).to include(SS::User::LOGIN_ROLE_SSO)
        expect(user.password).to be_blank
        expect(user.active?).to be_truthy
        expect(user.ldap_dn).to be_blank # ldap_dn には rkUid が含まれており、rkUid は守秘情報なので保存しないようにする
      end
      Gws::User.all.site(site).find_by(uid: Riken.encrypt("1005")).tap do |user|
        user.cur_site = site

        expect(user.i18n_name_translations[:ja]).to eq "斎藤 拓也"
        expect(user.i18n_name_translations[:en]).to eq "Saito Takkuya"
        expect(user.kana).to eq "サイトウ タクヤ"
        expect(user.email).to eq "user3@example.jp"
        expect(user.groups.count).to eq 2
        expect(user.groups.map(&:name)).to include("シラサギ大学", "シラサギ大学/企画政策部/広報課")
        expect(user.gws_main_group.name).to eq "シラサギ大学/企画政策部/広報課"
        # user "1005" is deleted from Slack
        expect(user.send_notice_slack_id).to be_blank
        expect(user.notice_circular_slack_user_setting).to eq "silence"
        expect(user.sys_role_ids).to include(sys_role1.id)
        expect(user.gws_role_ids).to include(sys_role1.id)

        expect(user.type).to eq SS::User::TYPE_SSO
        expect(user.login_roles).to include(SS::User::LOGIN_ROLE_SSO)
        expect(user.password).to be_blank
        expect(user.active?).to be_truthy
        expect(user.ldap_dn).to be_blank # ldap_dn には rkUid が含まれており、rkUid は守秘情報なので保存しないようにする
      end
      Gws::User.all.site(site).find_by(uid: Riken.encrypt("1006")).tap do |user|
        user.cur_site = site

        expect(user.i18n_name_translations[:ja]).to eq "伊藤 幸子"
        expect(user.i18n_name_translations[:en]).to eq "Ito Sachiko"
        expect(user.kana).to eq "イトウ サチコ"
        expect(user.email).to eq "user4@example.jp"
        expect(user.groups.count).to eq 3
        expect(user.groups.map(&:name)).to include("シラサギ大学", "シラサギ大学/危機管理部/管理課", "シラサギ大学/危機管理部/防災課")
        expect(user.gws_main_group.name).to eq "シラサギ大学/危機管理部/管理課"
        expect(user.send_notice_slack_id).to eq "50C14D2B4"
        expect(user.notice_circular_slack_user_setting).to eq "notify"
        expect(user.sys_role_ids).to include(sys_role1.id)
        expect(user.gws_role_ids).to include(sys_role1.id)

        expect(user.type).to eq SS::User::TYPE_SSO
        expect(user.login_roles).to include(SS::User::LOGIN_ROLE_SSO)
        expect(user.password).to be_blank
        expect(user.active?).to be_truthy
        expect(user.ldap_dn).to be_blank # ldap_dn には rkUid が含まれており、rkUid は守秘情報なので保存しないようにする
      end
      Gws::User.all.site(site).find_by(uid: Riken.encrypt("1007")).tap do |user|
        # グループ直下にユーザーがいるとのことで、グループ直下のユーザーが取り込めるかテスト
        user.cur_site = site

        expect(user.i18n_name_translations[:ja]).to eq "高橋 清"
        expect(user.i18n_name_translations[:en]).to eq "Takahashi Kiyoshi"
        expect(user.kana).to eq "タカハシ キヨシ"
        expect(user.email).to eq "user5@example.jp"
        expect(user.groups.count).to eq 1
        expect(user.groups.map(&:name)).to include("シラサギ大学")
        expect(user.gws_main_group.name).to eq "シラサギ大学"
        expect(user.send_notice_slack_id).to eq "C3FE211BE"
        expect(user.notice_circular_slack_user_setting).to eq "notify"
        expect(user.sys_role_ids).to include(sys_role1.id)
        expect(user.gws_role_ids).to include(sys_role1.id)

        expect(user.type).to eq SS::User::TYPE_SSO
        expect(user.login_roles).to include(SS::User::LOGIN_ROLE_SSO)
        expect(user.password).to be_blank
        expect(user.active?).to be_truthy
        expect(user.ldap_dn).to be_blank # ldap_dn には rkUid が含まれており、rkUid は守秘情報なので保存しないようにする
      end
      Gws::CustomGroup.all.site(site).first.tap do |custom_group|
        expect(custom_group.name).to eq custom_group_name1
        expect(custom_group.member_ids).to have(2).items
        expect(custom_group.members.map(&:email)).to include("user3@example.jp", "user4@example.jp")
        expect(custom_group.readable_setting_range).to eq "public"
      end

      #
      # 2nd attempts
      #
      save_group_count = Gws::Group.all.count
      save_user_count = Gws::User.all.count

      job = Riken::Ldap::ImportJob.new.bind("site_id" => site.id)
      job.instance_variable_set(:@ldap_searcher, csv_searcher1.new(user_csv_file, group_csv_file))
      expect { job.perform_now }.to output(include("グループ失敗件数: 0", "ユーザー失敗件数: 0", "ldap インポートを実行しました。")).to_stdout

      expect(Job::Log.count).to eq 2
      Job::Log.all.order_by(id: -1).first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)

        expect(log.logs).to include(/INFO -- : .* グループ成功件数: 6, グループ失敗件数: 0/)
        expect(log.logs).to include(/INFO -- : .* ユーザー成功件数: 7, ユーザー失敗件数: 0/)
      end

      expect(Gws::Group.all.active.count).to eq save_group_count
      expect(Gws::User.all.active.count).to eq save_user_count
    end
  end

  context "LDAP上のグループへのアクセスに失敗" do
    it do
      #
      # 1st attempts (same as usual case)
      #
      job = Riken::Ldap::ImportJob.new.bind("site_id" => site.id)
      job.instance_variable_set(:@ldap_searcher, csv_searcher1.new(user_csv_file, group_csv_file))
      expect { job.perform_now }.to output(include("グループ失敗件数: 0", "ユーザー失敗件数: 0", "ldap インポートを実行しました。")).to_stdout

      expect(Job::Log.count).to eq 1
      Job::Log.first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)

        expect(log.logs).to include(/INFO -- : .* グループ成功件数: 6, グループ失敗件数: 0/)
        expect(log.logs).to include(/INFO -- : .* ユーザー成功件数: 7, ユーザー失敗件数: 0/)
      end

      expect(Gws::Group.all.count).to eq 7
      expect(Gws::User.all.count).to eq 7

      #
      # 2nd attempts
      #
      save_group_count = Gws::Group.all.count
      save_user_count = Gws::User.all.count

      job = Riken::Ldap::ImportJob.new.bind("site_id" => site.id)
      job.instance_variable_set(:@ldap_searcher, csv_searcher2_raise_on_group.new(user_csv_file, group_csv_file))
      expect { job.perform_now }.to output(include("Timeout::Error")).to_stdout

      expect(Job::Log.count).to eq 2
      Job::Log.all.order_by(id: -1).first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/FATAL -- : .* Failed Job/)
        expect(log.logs).to include(/FATAL -- : .* Timeout::Error/)

        expect(log.logs).not_to include(/INFO -- : .* グループ成功件数/)
        expect(log.logs).not_to include(/INFO -- : .* ユーザー成功件数/)
      end

      expect(Gws::Group.all.active.count).to eq save_group_count
      expect(Gws::User.all.active.count).to eq save_user_count
    end
  end

  context "LDAP上のユーザーへのアクセスに失敗" do
    it do
      #
      # 1st attempts (same as usual case)
      #
      job = Riken::Ldap::ImportJob.new.bind("site_id" => site.id)
      job.instance_variable_set(:@ldap_searcher, csv_searcher1.new(user_csv_file, group_csv_file))
      expect { job.perform_now }.to output(include("グループ失敗件数: 0", "ユーザー失敗件数: 0", "ldap インポートを実行しました。")).to_stdout

      expect(Job::Log.count).to eq 1
      Job::Log.first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)

        expect(log.logs).to include(/INFO -- : .* グループ成功件数: 6, グループ失敗件数: 0/)
        expect(log.logs).to include(/INFO -- : .* ユーザー成功件数: 7, ユーザー失敗件数: 0/)
      end

      expect(Gws::Group.all.count).to eq 7
      expect(Gws::User.all.count).to eq 7

      #
      # 2nd attempts
      #
      save_group_count = Gws::Group.all.count
      save_user_count = Gws::User.all.count

      job = Riken::Ldap::ImportJob.new.bind("site_id" => site.id)
      job.instance_variable_set(:@ldap_searcher, csv_searcher3_raise_on_user.new(user_csv_file, group_csv_file))
      expect { job.perform_now }.to output(include("グループ失敗件数: 0", "Timeout::Error")).to_stdout

      expect(Job::Log.count).to eq 2
      Job::Log.all.order_by(id: -1).first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/FATAL -- : .* Failed Job/)
        expect(log.logs).to include(/FATAL -- : .* Timeout::Error/)

        expect(log.logs).to include(/INFO -- : .* グループ成功件数: 6, グループ失敗件数: 0/)
        expect(log.logs).not_to include(/INFO -- : .* ユーザー成功件数/)
      end

      expect(Gws::Group.all.active.count).to eq save_group_count
      expect(Gws::User.all.active.count).to eq save_user_count
    end
  end

  context "最初はうまく動作していたが、filter や dn の設定変更に失敗して 0 件になったケースを想定" do
    it do
      #
      # 1st attempts
      #
      job = Riken::Ldap::ImportJob.new.bind("site_id" => site.id)
      job.instance_variable_set(:@ldap_searcher, csv_searcher1.new(user_csv_file, group_csv_file))
      expect { job.perform_now }.to output(include("グループ失敗件数: 0", "ユーザー失敗件数: 0", "ldap インポートを実行しました。")).to_stdout

      expect(Job::Log.count).to eq 1
      Job::Log.first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)

        expect(log.logs).to include(/INFO -- : .* グループ成功件数: 6, グループ失敗件数: 0/)
        expect(log.logs).to include(/INFO -- : .* ユーザー成功件数: 7, ユーザー失敗件数: 0/)
      end

      expect(Gws::Group.all.count).to eq 7
      expect(Gws::Group.all.active.count).to eq 7
      expect(Gws::User.all.count).to eq 7
      expect(Gws::User.all.active.count).to eq 7

      #
      # 2nd attempts
      #
      save_group_count = Gws::Group.all.count
      save_user_count = Gws::User.all.count

      job = Riken::Ldap::ImportJob.new.bind("site_id" => site.id)
      job.instance_variable_set(:@ldap_searcher, csv_searcher4_empties.new(user_csv_file, group_csv_file))
      expect { job.perform_now }.to output(include("グループ失敗件数: 0", "ユーザー失敗件数: 0", "ldap インポートを実行しました。")).to_stdout

      expect(Job::Log.count).to eq 2
      Job::Log.all.order_by(id: -1).first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)

        expect(log.logs).to include(/INFO -- : .* グループ成功件数: 0, グループ失敗件数: 0/)
        expect(log.logs).to include(/INFO -- : .* ユーザー成功件数: 0, ユーザー失敗件数: 0/)
      end

      expect(Gws::Group.all.active.count).to eq save_group_count
      expect(Gws::User.all.active.count).to eq save_user_count
    end
  end

  context "ローカルユーザー（シラサギユーザー）が存在するケースを想定" do
    let!(:user1) do
      create(
        :gws_user, cur_site: site, cur_group: site, cur_user: nil,
        sys_role_ids: [ sys_role1.id ], gws_role_ids: [ gws_role1.id ]
      )
    end
    let!(:user2) do
      create(
        :gws_user, cur_site: site, cur_group: site, cur_user: nil, account_expiration_date: 1.hour.ago,
        sys_role_ids: [ sys_role1.id ], gws_role_ids: [ gws_role1.id ]
      )
    end

    it do
      expect(Gws::Group.all.count).to eq 1
      expect(Gws::Group.all.active.count).to eq 1
      expect(Gws::User.all.count).to eq 2
      expect(Gws::User.all.active.count).to eq 1

      job = Riken::Ldap::ImportJob.new.bind("site_id" => site.id)
      job.instance_variable_set(:@ldap_searcher, csv_searcher1.new(user_csv_file, group_csv_file))
      expect { job.perform_now }.to output(include("グループ失敗件数: 0", "ユーザー失敗件数: 0", "ldap インポートを実行しました。")).to_stdout

      expect(Job::Log.count).to eq 1
      Job::Log.first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)

        expect(log.logs).to include(/INFO -- : .* グループ成功件数: 6, グループ失敗件数: 0/)
        expect(log.logs).to include(/INFO -- : .* ユーザー成功件数: 7, ユーザー失敗件数: 0/)
      end

      expect(Gws::Group.all.count).to eq 7
      expect(Gws::Group.all.active.count).to eq 7
      expect(Gws::User.all.count).to eq 9
      expect(Gws::User.all.active.count).to eq 8

      expect { user1.reload }.not_to raise_error
      expect { user2.reload }.not_to raise_error
    end
  end
end
