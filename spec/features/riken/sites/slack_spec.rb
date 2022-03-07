require 'spec_helper'

describe Gws::SitesController, type: :feature, dbscope: :example, js: true do
  let!(:site) { gws_site }
  let(:requests) { [] }

  before do
    @net_connect_allowed = WebMock.net_connect_allowed?
    WebMock.disable_net_connect!(allow_localhost: "127.0.0.1")

    stub_request(:post, "https://slack.com/api/auth.test").
      to_return(status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/riken/auth_test1.json"), headers: {})
    stub_request(:post, "https://slack.com/api/conversations.list").
      to_return(status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/riken/conversations_list1.json"), headers: {})
    stub_request(:post, "https://slack.com/api/conversations.join").
      to_return(status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/riken/conversations_join1.json"), headers: {})
    stub_request(:any, "https://slack.com/api/chat.postMessage").to_return do |request|
      requests << request.as_json.dup
      { status: 200, body: ::File.binread("#{Rails.root}/spec/fixtures/gws/circular/post_message.json"),
        headers: {'Content-Type' => 'application/json'} }
    end

    login_gws_user
  end

  after do
    WebMock.reset!
    WebMock.allow_net_connect! if @net_connect_allowed
  end

  context "when slack_oauth_token is tested" do
    it do
      visit gws_site_path(site: site)
      click_on I18n.t("ss.links.edit")

      within "#item-form" do
        fill_in "item[slack_oauth_token]", with: unique_id

        click_on I18n.t("riken.ldap.test_connection")

        expect(page).to have_css(".ldap-test-result", text: "login success to 'example'")
      end
    end
  end

  context "when notice_slack_channels is tested" do
    let(:notice_slack_channel) { "#example" }

    it do
      visit gws_site_path(site: site)
      click_on I18n.t("ss.links.edit")

      within "#item-form" do
        fill_in "item[slack_oauth_token]", with: unique_id

        ensure_addon_opened("#addon-gws-agents-addons-notice-group_setting")
        within "#addon-gws-agents-addons-notice-group_setting" do
          click_on I18n.t("ss.buttons.add")

          within first("[data-index='1']") do
            fill_in "item[notice_slack_channels][]", with: notice_slack_channel
            click_on I18n.t("riken.slack.test_channel")

            expect(page).to have_css(".ldap-test-result", text: "channel '#{notice_slack_channel}' looks good")
          end
        end
      end
    end
  end

  context "when notice_slack_channels is joined" do
    let(:notice_slack_channel) { "#example" }

    it do
      visit gws_site_path(site: site)
      click_on I18n.t("ss.links.edit")

      within "#item-form" do
        fill_in "item[slack_oauth_token]", with: unique_id

        ensure_addon_opened("#addon-gws-agents-addons-notice-group_setting")
        within "#addon-gws-agents-addons-notice-group_setting" do
          click_on I18n.t("ss.buttons.add")

          within first("[data-index='1']") do
            fill_in "item[notice_slack_channels][]", with: notice_slack_channel
            click_on I18n.t("riken.slack.join_channel")

            expect(page).to have_css(".ldap-test-result", text: "already in channel '#{notice_slack_channel}'")
          end
        end
      end
    end
  end

  context "when notice_slack_channels is tested a post" do
    let(:notice_slack_channel) { "#example" }

    it do
      visit gws_site_path(site: site)
      click_on I18n.t("ss.links.edit")

      within "#item-form" do
        fill_in "item[slack_oauth_token]", with: unique_id

        ensure_addon_opened("#addon-gws-agents-addons-notice-group_setting")
        within "#addon-gws-agents-addons-notice-group_setting" do
          click_on I18n.t("ss.buttons.add")

          within first("[data-index='1']") do
            fill_in "item[notice_slack_channels][]", with: notice_slack_channel
            click_on I18n.t("riken.slack.test_post")

            expect(page).to have_css(".ldap-test-result", text: "success")
          end
        end
      end

      expect(requests.length).to eq 1

      channels = []
      requests.each do |request|
        body = Hash[URI.decode_www_form(request["body"])]
        channels << body["channel"]
      end
      expect(channels.length).to eq requests.length
      expect(channels[0]).to eq notice_slack_channel
    end
  end

  context "when circular_slack_channels is tested" do
    let(:circular_slack_channel) { "#example" }

    it do
      visit gws_site_path(site: site)
      click_on I18n.t("ss.links.edit")

      within "#item-form" do
        fill_in "item[slack_oauth_token]", with: unique_id

        ensure_addon_opened("#addon-gws-agents-addons-circular-group_setting")
        within "#addon-gws-agents-addons-circular-group_setting" do
          click_on I18n.t("ss.buttons.add")

          within first("[data-index='1']") do
            fill_in "item[circular_slack_channels][]", with: circular_slack_channel
            click_on I18n.t("riken.slack.test_channel")

            expect(page).to have_css(".ldap-test-result", text: "channel '#{circular_slack_channel}' looks good")
          end
        end
      end
    end
  end

  context "when circular_slack_channels is joined" do
    let(:circular_slack_channel) { "#example" }

    it do
      visit gws_site_path(site: site)
      click_on I18n.t("ss.links.edit")

      within "#item-form" do
        fill_in "item[slack_oauth_token]", with: unique_id

        ensure_addon_opened("#addon-gws-agents-addons-circular-group_setting")
        within "#addon-gws-agents-addons-circular-group_setting" do
          click_on I18n.t("ss.buttons.add")

          within first("[data-index='1']") do
            fill_in "item[circular_slack_channels][]", with: circular_slack_channel
            click_on I18n.t("riken.slack.join_channel")

            expect(page).to have_css(".ldap-test-result", text: "already in channel '#{circular_slack_channel}'")
          end
        end
      end
    end
  end

  context "when circular_slack_channels is tested a post" do
    let(:circular_slack_channel) { "#example" }

    it do
      visit gws_site_path(site: site)
      click_on I18n.t("ss.links.edit")

      within "#item-form" do
        fill_in "item[slack_oauth_token]", with: unique_id

        ensure_addon_opened("#addon-gws-agents-addons-circular-group_setting")
        within "#addon-gws-agents-addons-circular-group_setting" do
          click_on I18n.t("ss.buttons.add")

          within first("[data-index='1']") do
            fill_in "item[circular_slack_channels][]", with: circular_slack_channel
            click_on I18n.t("riken.slack.test_post")

            expect(page).to have_css(".ldap-test-result", text: "success")
          end
        end
      end

      expect(requests.length).to eq 1

      channels = []
      requests.each do |request|
        body = Hash[URI.decode_www_form(request["body"])]
        channels << body["channel"]
      end
      expect(channels.length).to eq requests.length
      expect(channels[0]).to eq circular_slack_channel
    end
  end
end
