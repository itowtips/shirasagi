require 'spec_helper'

describe Riken::Auth::ShibbolethsController, type: :feature, dbscope: :example, js: true do
  before { login_sys_user }

  context "basic crud" do
    let(:name) { "name-#{unique_id}" }
    let(:name2) { "name-#{unique_id}" }
    let(:filename) { "filename-#{unique_id}" }
    let(:key) { "key-#{unique_id}" }
    let(:login_url) { unique_url }

    it do
      #
      # Create
      #
      visit riken_auth_shibboleths_path
      within ".nav-menu" do
        click_on I18n.t("ss.links.new")
      end

      within "form#item-form" do
        fill_in "item[name]", with: name
        fill_in "item[filename]", with: filename
        fill_in "item[keys]", with: key
        fill_in "item[login_url]", with: login_url

        click_on I18n.t("ss.buttons.save")
      end
      wait_for_notice I18n.t("ss.notice.saved")

      expect(Riken::Auth::Shibboleth.all.count).to eq 1
      Riken::Auth::Shibboleth.first.tap do |auth|
        expect(auth.model).to eq Riken::Auth::Shibboleth.model_name.name.underscore
        expect(auth.name).to eq name
        expect(auth.filename).to eq filename
        expect(auth.text).to be_blank
        expect(auth.order).to eq 0
        expect(auth.state).to eq "enabled"
        expect(auth.keys.length).to eq 1
        expect(auth.keys).to include(key)
        expect(auth.login_url).to eq login_url
      end

      #
      # Update
      #
      visit riken_auth_shibboleths_path
      click_on name
      within ".nav-menu" do
        click_on I18n.t("ss.links.edit")
      end
      within "form#item-form" do
        fill_in "item[name]", with: name2
        click_on I18n.t("ss.buttons.save")
      end
      wait_for_notice I18n.t("ss.notice.saved")

      expect(Riken::Auth::Shibboleth.all.count).to eq 1
      Riken::Auth::Shibboleth.first.tap do |auth|
        expect(auth.name).to eq name2
      end

      #
      # Delete
      #
      visit riken_auth_shibboleths_path
      click_on name2
      within ".nav-menu" do
        click_on I18n.t("ss.links.delete")
      end
      within "form" do
        click_on I18n.t("ss.buttons.delete")
      end
      wait_for_notice I18n.t("ss.notice.deleted")
    end
  end
end
