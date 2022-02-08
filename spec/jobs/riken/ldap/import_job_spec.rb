require 'spec_helper'

describe Riken::Ldap::ImportJob, dbscope: :example do
  let!(:site) { Gws::Group.create(name: "シラサギ市", ldap_dn: "labCd=100001,OU=Organizations,O=example,C=jp") }
  let(:user_csv_file) { "#{Rails.root}/spec/fixtures/riken/ldap_user1.csv" }
  let(:group_csv_file) { "#{Rails.root}/spec/fixtures/riken/ldap_group1.csv" }

  before do
    @net_connect_allowed = WebMock.net_connect_allowed?
    WebMock.disable_net_connect!

    stub_request(:post, "https://slack.com/api/auth.test").
      to_return(status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/riken/auth_test1.json"), headers: {})
    stub_request(:post, "https://slack.com/api/users.list").
      to_return(status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/riken/users_list1.json"), headers: {})

    site.slack_oauth_token = unique_id
    site.save!
  end

  after do
    WebMock.reset!
    WebMock.allow_net_connect! if @net_connect_allowed
  end

  it do
    job = Riken::Ldap::ImportJob.new.bind("site_id" => site.id)
    job.instance_variable_set(:@ldap_searcher, Riken::Ldap::CsvSearcher.new(user_csv_file, group_csv_file))
    expect { job.perform_now }.to output(include("グループ失敗件数: 0", "ユーザー失敗件数: 0")).to_stdout

    expect(Job::Log.count).to eq 1
    Job::Log.first.tap do |log|
      expect(log.logs).to include(/INFO -- : .* Started Job/)
      expect(log.logs).to include(/INFO -- : .* Completed Job/)

      expect(log.logs).to include(/INFO -- : .* グループ成功件数: #{Gws::Group.all.count}, グループ失敗件数: 0/)
      expect(log.logs).to include(/INFO -- : .* ユーザー成功件数: #{Gws::User.all.count}, ユーザー失敗件数: 0/)
    end

    expect(Gws::Group.all.count).to eq 7

    site.reload
    expect(site.i18n_name_translations[:ja]).to eq "シラサギ市"
    expect(site.i18n_name_translations[:en]).to eq "Shirasagi City"

    Gws::Group.all.site(site).find_by(ldap_dn: "labCd=111001,OU=Organizations,O=example,C=jp").tap do |group|
      expect(group.i18n_name_translations[:ja]).to eq "シラサギ市/企画政策部/政策課"
      expect(group.i18n_name_translations[:en]).to eq "Shirasagi City/Kikaku Seisaku Department/Seisaku Section"
    end

    Gws::User.all.site(site).find_by(uid: Riken.encrypt("1001")).tap do |user|
      user.cur_site = site

      expect(user.i18n_name_translations[:ja]).to eq "システム管理者"
      expect(user.i18n_name_translations[:en]).to eq "System Admin"
      expect(user.kana).to eq "システムカンリシャ"
      expect(user.email).to eq "sys@example.jp"
      expect(user.groups.count).to eq 1
      expect(user.groups.map(&:name)).to include("シラサギ市/企画政策部/政策課")
      expect(user.gws_main_group.name).to eq "シラサギ市/企画政策部/政策課"
      expect(user.send_notice_slack_id).to be_blank

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
      expect(user.groups.count).to eq 1
      expect(user.groups.map(&:name)).to include("シラサギ市/企画政策部/広報課")
      expect(user.gws_main_group.name).to eq "シラサギ市/企画政策部/広報課"
      # user "1005" is deleted from Slack
      expect(user.send_notice_slack_id).to be_blank

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
      expect(user.groups.count).to eq 2
      expect(user.groups.map(&:name)).to include("シラサギ市/危機管理部/管理課", "シラサギ市/危機管理部/防災課")
      expect(user.gws_main_group.name).to eq "シラサギ市/危機管理部/管理課"
      expect(user.send_notice_slack_id).to eq "50C14D2B4"

      expect(user.type).to eq SS::User::TYPE_SSO
      expect(user.login_roles).to include(SS::User::LOGIN_ROLE_SSO)
      expect(user.password).to be_blank
      expect(user.active?).to be_truthy
      expect(user.ldap_dn).to be_blank # ldap_dn には rkUid が含まれており、rkUid は守秘情報なので保存しないようにする
    end
  end
end
