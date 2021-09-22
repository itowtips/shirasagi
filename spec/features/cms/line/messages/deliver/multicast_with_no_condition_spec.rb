require 'spec_helper'

describe "cms/line/messages deliver multicast_with_no_condition", type: :feature, dbscope: :example, js: true do
  let(:site) { cms_site }

  let(:index_path) { cms_line_messages_path site }
  let(:new_path) { new_cms_line_message_path site }
  let(:logs_path) { cms_line_deliver_logs_path site }

  # active members
  let!(:member1) do
    create :cms_member, cur_site: site, oauth_id: unique_id, oauth_type: "line", subscribe_line_message: "active"
  end
  let!(:member2) do
    create :cms_member, cur_site: site, oauth_id: unique_id, oauth_type: "line", subscribe_line_message: "active",
      child1_birthday: Date.parse("2000/11/11"), child2_birthday: Date.parse("2001/1/1")
  end
  let!(:member3) do
    create :cms_member, cur_site: site, oauth_id: unique_id, oauth_type: "line", subscribe_line_message: "active",
      residence_areas: %w(nakaku higashiku)
  end

  # expired members
  let!(:member4) do
    create :cms_member, cur_site: site, subscribe_line_message: "active"
  end
  let!(:member5) do
    create :cms_member, cur_site: site, oauth_id: unique_id, oauth_type: "line", subscribe_line_message: "expired"
  end
  let!(:member6) do
    create :cms_member, cur_site: site, oauth_id: unique_id, oauth_type: "line", subscribe_line_message: "active", state: "disabled"
  end

  let(:active_members_count) { "#{I18n.t("cms.member")}3#{I18n.t("ss.units.count")}" }
  let(:active_members_user_ids) { [member1, member2, member3].map(&:oauth_id) }
  let(:message) { Cms::Line::Message.site(site).first }

  def add_template
    within "#addon-cms-agents-addons-line-message-body" do
      click_on "テンプレートを追加する（最大5個）"
    end

    within ".line-select-message-type" do
      first(".message-type.text").click
    end

    within "#addon-cms-agents-addons-line-template-text" do
      expect(page).to have_css("h2", text: I18n.t("modules.addons.cms/line/template/text"))
      fill_in "item[text]", with: unique_id
    end

    within "footer.send" do
      click_on I18n.t("ss.buttons.save")
    end
    expect(page).to have_css('#notice', text: I18n.t('ss.notice.saved'))
  end

  def check_deliver_members
    first(".ajax-box", text: "確認する").click
    wait_for_cbox do
      expect(page).to have_css("#ajax-box", text: active_members_count)
      expect(page).to have_css(".list-item", text: member1.name)
      expect(page).to have_css(".list-item", text: member1.oauth_id)
      expect(page).to have_css(".list-item", text: member2.name)
      expect(page).to have_css(".list-item", text: member2.oauth_id)
      expect(page).to have_css(".list-item", text: member3.name)
      expect(page).to have_css(".list-item", text: member3.oauth_id)
      expect(page).to have_no_css(".list-item", text: member4.name)
      expect(page).to have_no_css(".list-item", text: member5.name)
      expect(page).to have_no_css(".list-item", text: member5.oauth_id)
      expect(page).to have_no_css(".list-item", text: member6.name)
      expect(page).to have_no_css(".list-item", text: member6.oauth_id)
      first("#cboxClose").click
    end
    expect(page).to have_css(".ajax-box", text: "確認する")
  end

  def execute_job
    Cms::Line::DeliverJob.bind(site_id: site).perform_now(message.id)
  end

  before do
    site.line_channel_secret = unique_id
    site.line_channel_access_token = unique_id
    site.save!
  end

  describe "basic crud" do
    before { login_cms_user }

    it "#new" do
      visit new_path
      within "form#item-form" do
        fill_in "item[name]", with: "sample"
        select I18n.t("cms.options.line_deliver_condition_state.multicast_with_no_condition"), from: 'item[deliver_condition_state]'
        click_on I18n.t("ss.buttons.save")
      end
      expect(page).to have_css('#notice', text: I18n.t('ss.notice.saved'))

      within "#addon-basic" do
        expect(page).to have_css("dd", text: I18n.t("cms.options.deliver_state.draft"))
      end
      within "#menu" do
        expect(page).to have_no_link I18n.t("ss.links.deliver")
      end
      check_deliver_members

      add_template

      within "#menu" do
        expect(page).to have_link I18n.t("ss.links.deliver")
        click_on I18n.t("ss.links.deliver")
      end

      within ".main-box" do
        expect(page).to have_css("header", text: I18n.t("cms.options.deliver_mode.main"))
        expect(page).to have_css("dd", text: active_members_count)
      end
      check_deliver_members

      within "footer.send" do
        page.accept_confirm do
          click_on I18n.t("ss.links.deliver")
        end
      end
      expect(page).to have_css('#notice', text: I18n.t('ss.notice.started_deliver'))

      within "#addon-basic" do
        expect(page).to have_css("dd", text: I18n.t("cms.options.deliver_state.ready"))
      end
      expect(enqueued_jobs.size).to eq 1
      expect(enqueued_jobs[0][:job]).to eq Cms::Line::DeliverJob

      capture_line_bot_client do |capture|
        execute_job
        expect(capture.multicast.count).to eq 1
        expect(capture.multicast.user_ids).to match_array active_members_user_ids
        expect(Cms::SnsPostLog::LineDeliver.count).to eq 1
      end
      visit index_path
      within ".list-items" do
        expect(page).to have_css(".list-item .title", text: message.name)
        expect(page).to have_css(".list-item .meta .state-completed", text: I18n.t("cms.options.deliver_state.completed"))
      end

      visit logs_path
      within ".list-items" do
        expect(page).to have_css(".list-item .title", text: "[#{I18n.t("cms.options.deliver_mode.main")}] #{message.name}")
        expect(page).to have_css(".list-item .meta .action", text: "multicast")
        expect(page).to have_css(".list-item .meta .state", text: I18n.t("cms.options.sns_post_log_state.success"))
      end
    end
  end
end
