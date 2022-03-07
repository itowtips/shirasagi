require 'spec_helper'

describe "gws_login", type: :feature, dbscope: :example, js: true do
  let(:site) { gws_site }
  let(:user) { gws_user }

  context "with regular user" do
    it do
      login_user user

      visit gws_portal_path(site: site)

      find("span.name").click
      within "#user-main-dropdown" do
        expect(page).to have_link(I18n.t("ss.logout"), href: sns_logout_path)

        click_on I18n.t("ss.logout")
      end

      expect(page).to have_css(".login-box", text: I18n.t("ss.login", locale: I18n.default_locale))
    end
  end

  context "with sso user" do
    it do
      login_user user
      user.update(type: SS::User::TYPE_SSO)

      visit gws_portal_path(site: site)

      find("span.name").click
      within "#user-main-dropdown" do
        expect(page).to have_no_link(I18n.t("ss.logout"), href: sns_logout_path)
      end
    end
  end
end
