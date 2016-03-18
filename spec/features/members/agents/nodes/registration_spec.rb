require 'spec_helper'

describe 'members/agents/nodes/registration', type: :feature, dbscope: :example do
  let(:site) { cms_site }
  let!(:node_mypage) { create :member_node_mypage, site: site, html: '<div id="mypage"></div>' }
  let(:reply_upper_text) do
    %w(
      会員登録ありがとうございました。
      次の URL をクリックし、画面の指示にしたがって会員登録を完了させてください。).join("\n")
  end
  let(:reset_password_upper_text) do
    %w(
      ログインパスワードの再設定用のURLをお送りします。
      次の URL をクリックし、画面の指示にしたがってパスワード再設定を完了させてください。).join("\n")
  end
  let!(:node_registration) do
    create(
      :member_node_registration,
      cur_site: site,
      sender_name: '会員登録',
      sender_email: 'admin@example.jp',
      subject: '登録確認',
      reply_upper_text: reply_upper_text,
      reply_lower_text: '本メールに心当たりのない方は、お手数ですがメールを削除してください。',
      reply_signature: "----\nシラサギ市",
      reset_password_subject: 'パスワード再設定案内',
      reset_password_upper_text: reset_password_upper_text,
      reset_password_lower_text: "本メールに心当たりのない方は、お手数ですがメールを削除してください。",
      reset_password_signature: "----\nシラサギ市")
  end
  let!(:node_login) do
    create(
      :member_node_login,
      cur_site: site,
      redirect_url: node_mypage.url,
      form_auth: "enabled",
      twitter_oauth: "disabled",
      facebook_oauth: "disabled")
  end
  let(:index_path) { node_registration.full_url }

  before do
    ActionMailer::Base.deliveries = []
  end

  after do
    ActionMailer::Base.deliveries = []
  end

  describe "register new member" do
    let(:name) { unique_id }
    let(:email) { "#{unique_id}@example.jp" }
    let(:kana) { unique_id }
    let(:tel) { unique_id }
    let(:addr) { unique_id }
    let(:sex_label) { "男性" }
    let(:sex) { "male" }
    let(:era) { "西暦" }
    let(:birthday) { Date.parse("1985-01-01") }
    let(:password) { "abc123" }

    it do
      visit index_path

      within "form" do
        fill_in "item[name]", with: name
        fill_in "item[email]", with: email
        fill_in "item[email_again]", with: email
        fill_in "item[kana]", with: kana
        fill_in "item[tel]", with: tel
        fill_in "item[addr]", with: addr
        select sex_label, from: "item[sex]"
        select era, from: "item[in_birth][era]"
        fill_in "item[in_birth][year]", with: birthday.year
        select birthday.month, from: "item[in_birth][month]"
        select birthday.day, from: "item[in_birth][day]"

        click_button "確認画面へ"
      end

      within "form" do
        expect(page.find("input[name='item[name]']", visible: false).value).to eq name
        expect(page.find("input[name='item[email]']", visible: false).value).to eq email
        expect(page.find("input[name='item[kana]']", visible: false).value).to eq kana
        expect(page.find("input[name='item[tel]']", visible: false).value).to eq tel
        expect(page.find("input[name='item[addr]']", visible: false).value).to eq addr
        expect(page.find("input[name='item[sex]']", visible: false).value).to eq sex
        expect(page.find("input[name='item[in_birth][era]']", visible: false).value).to eq era
        expect(page.find("input[name='item[in_birth][year]']", visible: false).value).to eq birthday.year.to_s
        expect(page.find("input[name='item[in_birth][month]']", visible: false).value).to eq birthday.month.to_s
        expect(page.find("input[name='item[in_birth][day]']", visible: false).value).to eq birthday.day.to_s

        click_button "登録"
      end

      expect(ActionMailer::Base.deliveries.length).to eq 1
      mail = ActionMailer::Base.deliveries.first
      expect(mail.from.first).to eq "admin@example.jp"
      expect(mail.to.first).to eq email
      expect(mail.subject).to eq '登録確認'
      expect(mail.body.raw_source).to include(node_registration.reply_upper_text)
      expect(mail.body.raw_source).to include(node_registration.reply_lower_text)
      expect(mail.body.raw_source).to include(node_registration.reply_signature)

      member = Cms::Member.where(email: email).first
      expect(member.name).to eq name
      expect(member.email).to eq email
      expect(member.state).to eq "temporary"
      expect(member.kana).to eq kana
      expect(member.tel).to eq tel
      expect(member.addr).to eq addr
      expect(member.sex).to eq sex
      expect(member.birthday).to eq birthday

      mail.body.raw_source =~ /(#{Regexp.escape(node_registration.full_url)}[^ \t\r\n]+)/
      url = $1
      expect(url).not_to be_nil
      visit url

      within "form" do
        expect(page).to have_css(".colum dd", text: name)
        expect(page).to have_css(".colum dd", text: email)
        fill_in "item[in_password]", with: password
        fill_in "item[in_password_again]", with: password

        click_button "登録"
      end

      member = Cms::Member.where(email: email).first
      expect(member.name).to eq name
      expect(member.email).to eq email
      expect(member.state).to eq "enabled"
      expect(member.kana).to eq kana
      expect(member.tel).to eq tel
      expect(member.addr).to eq addr
      expect(member.sex).to eq sex
      expect(member.birthday).to eq birthday

      click_link "ログイン"

      within "form" do
        fill_in "item[email]", with: email
        fill_in "item[password]", with: password

        click_button "ログイン"
      end

      expect(page). to have_css("div#mypage")
    end
  end

  describe "only fill requried fields" do
    let(:name) { unique_id }
    let(:email) { "#{unique_id}@example.jp" }

    it do
      visit index_path

      within "form" do
        fill_in "item[name]", with: name
        fill_in "item[email]", with: email
        fill_in "item[email_again]", with: email

        click_button "確認画面へ"
      end

      within "form" do
        expect(page.find("input[name='item[name]']", visible: false).value).to eq name
        expect(page.find("input[name='item[email]']", visible: false).value).to eq email
        expect(page.find("input[name='item[kana]']", visible: false).value).to eq ""
        expect(page.find("input[name='item[tel]']", visible: false).value).to eq ""
        expect(page.find("input[name='item[addr]']", visible: false).value).to eq ""
        expect(page.find("input[name='item[sex]']", visible: false).value).to eq ""
        expect(page.find("input[name='item[in_birth][era]']", visible: false).value).to be_nil
        expect(page.find("input[name='item[in_birth][year]']", visible: false).value).to be_nil
        expect(page.find("input[name='item[in_birth][month]']", visible: false).value).to be_nil
        expect(page.find("input[name='item[in_birth][day]']", visible: false).value).to be_nil

        click_button "登録"
      end

      expect(ActionMailer::Base.deliveries.length).to eq 1
      mail = ActionMailer::Base.deliveries.first
      expect(mail.from.first).to eq "admin@example.jp"
      expect(mail.to.first).to eq email
      expect(mail.subject).to eq '登録確認'
      expect(mail.body.raw_source).to include(node_registration.reply_upper_text)
      expect(mail.body.raw_source).to include(node_registration.reply_lower_text)
      expect(mail.body.raw_source).to include(node_registration.reply_signature)

      member = Cms::Member.where(email: email).first
      expect(member.name).to eq name
      expect(member.email).to eq email
      expect(member.kana).to be_nil
      expect(member.tel).to be_nil
      expect(member.addr).to be_nil
      expect(member.sex).to be_nil
      expect(member.birthday).to be_nil
    end
  end
end
