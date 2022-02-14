require 'spec_helper'

describe Riken::Login::ShibbolethController, type: :feature, dbscope: :example, js: true do
  let!(:auth) do
    Riken::Auth::Shibboleth.create!(
      name: "name-#{unique_id}", filename: "filename-#{unique_id}", keys: "key-#{unique_id}".upcase,
      login_url: unique_url + "?shibboleth-login"
    )
  end

  context "without environments" do
    let!(:site) { gws_site }

    it do
      visit sns_login_path(ref: gws_portal_path(site: site))
      click_on auth.name

      expect(page.current_url).to end_with("?shibboleth-login")
    end
  end

  context "with users" do
    let!(:site) { gws_site }
    let(:uid) { "uid-#{unique_id}" }

    before do
      SS::Application.request_interceptor = proc do |env|
        env[auth.keys.first] = uid
      end
    end

    after do
      SS::Application.request_interceptor = nil
    end

    context "with valid user" do
      let!(:user) { create :gws_user, cur_group: site, uid: Riken.encrypt(uid) }

      it do
        visit sns_login_path(ref: gws_portal_path(site: site))
        click_on auth.name

        expect(page.current_path).to eq gws_portal_path(site: site)
      end
    end

    context "with disabled user" do
      let!(:user) { create :gws_user, cur_group: site, uid: Riken.encrypt(uid), account_expiration_date: 1.minute.ago }

      it do
        visit sns_login_path(ref: gws_portal_path(site: site))
        click_on auth.name

        # login controller in test always uses default locale
        text = I18n.t("riken.shibboleth.login_failed.head", locale: I18n.default_locale)
        expect(page).to have_css("#addon-basic h2", text: text)
      end
    end
  end
end
