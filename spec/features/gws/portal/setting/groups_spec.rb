require 'spec_helper'

describe "gws_portal_setting_groups", type: :feature, dbscope: :example, js: true do
  let(:site) { gws_site }
  let(:user) { gws_user }

  before { create_default_portal }

  context "with auth" do
    before { login_gws_user }

    it "#index" do
      visit gws_portal_path(site: site)
      expect(page).to have_no_content(I18n.t('gws/portal.group_portal'))

      visit gws_portal_group_path(site: site, group: site)
      #expect(page).to have_content(I18n.t('gws/portal.group_portal'))

      visit gws_portal_setting_groups_path(site: site)
      expect(page).to have_content(user.groups.first.trailing_name)

      # secured
      role = user.gws_roles[0]
      role.update(permissions: [])
      user.clear_gws_role_permissions

      visit gws_site_path(site: site)
      expect(page).to have_no_content(I18n.t('gws/portal.group_portal'))

      visit gws_portal_setting_groups_path(site: site)
      expect(page).to have_title("403")
    end
  end

  context "least required permissions to manage" do
    let!(:notice_folder) { create(:gws_notice_folder, cur_site: site) }
    let!(:notice_post) { create(:gws_notice_post, cur_site: site, folder_id: notice_folder) }
    let!(:schedule_plan) { create(:gws_schedule_plan, cur_site: site) }
    let(:permissions) do
      permissions = []
      permissions << 'use_gws_portal_group_settings'
      permissions << 'read_private_gws_portal_group_settings'
      permissions << 'edit_private_gws_portal_group_settings'
      permissions << 'delete_private_gws_portal_group_settings'
      # ポータルにお知らせを表示するために必要
      permissions << 'use_gws_notice'
      permissions << 'read_private_gws_notices'
      # ポータルにスケジュールを表示するために必要
      permissions << 'use_private_gws_schedule_plans'
      permissions << 'read_private_gws_schedule_plans'
      permissions
    end
    let(:role) { create(:gws_role, cur_site: site, permissions: permissions) }

    before do
      user.gws_role_ids = [role.id]
      user.save!

      login_user user
    end

    it do
      visit gws_portal_path(site: site)
      expect(page).to have_css(".gws-notices", text: notice_post.name)
      expect(page).to have_css(".gws-portlets .portlet-model-schedule", text: schedule_plan.name)
      within ".current-navi" do
        click_on user.groups.first.trailing_name
      end
      within ".breadcrumb" do
        expect(page).to have_content(user.groups.first.trailing_name)
      end
      within ".current-navi" do
        expect(page).to have_content(I18n.t('gws/portal.links.arrange_portlets'))
        expect(page).to have_content(I18n.t('gws/portal.links.manage_portlets'))
      end

      click_on I18n.t('gws/portal.links.arrange_portlets')
      click_on I18n.t("ss.buttons.reset")
      expect(page).to have_css(".gws-portlets .portlet-model-schedule", text: schedule_plan.name)

      click_on I18n.t('gws/portal.links.manage_portlets')
      click_on I18n.t('gws/portal.sync_preset')
      within "form .gws-tabs" do
        click_on I18n.t('ss.buttons.sync')
      end
      within "form footer.send" do
        page.accept_alert(/#{::Regexp.escape(I18n.t("ss.confirm.sync"))}/) do
          click_on I18n.t('ss.buttons.sync')
        end
      end
      expect(page).to have_css('#notice', text: I18n.t("ss.notice.synced"))

      click_on I18n.t('gws/portal.sync_preset')
      within "form .gws-tabs" do
        click_on I18n.t('ss.buttons.initialize')
      end
      within "form footer.send" do
        page.accept_alert(/#{::Regexp.escape(I18n.t("ss.confirm.initialize"))}/) do
          click_on I18n.t('ss.buttons.initialize')
        end
      end
      expect(page).to have_css('#notice', text: I18n.t("ss.notice.initialized"))
    end
  end

  context "least required permissions to show" do
    let!(:notice_folder) { create(:gws_notice_folder, cur_site: site) }
    let!(:notice_post) { create(:gws_notice_post, cur_site: site, folder_id: notice_folder) }
    let!(:schedule_plan) { create(:gws_schedule_plan, cur_site: site) }
    let(:permissions) do
      permissions = []
      permissions << 'use_gws_portal_group_settings'
      # ポータルにお知らせを表示するために必要
      permissions << 'use_gws_notice'
      permissions << 'read_private_gws_notices'
      # ポータルにスケジュールを表示するために必要
      permissions << 'use_private_gws_schedule_plans'
      permissions << 'read_private_gws_schedule_plans'
      permissions
    end
    let(:role) { create(:gws_role, cur_site: site, permissions: permissions) }

    before do
      user.gws_role_ids = [role.id]
      user.save!

      login_user user
    end

    it do
      visit gws_portal_path(site: site)
      expect(page).to have_css(".gws-notices", text: notice_post.name)
      expect(page).to have_css(".gws-portlets .portlet-model-schedule", text: schedule_plan.name)
      within ".current-navi" do
        click_on user.groups.first.trailing_name
      end
      within ".breadcrumb" do
        expect(page).to have_content(user.groups.first.trailing_name)
      end
      within ".current-navi" do
        expect(page).to have_no_content(I18n.t('gws/portal.links.arrange_portlets'))
        expect(page).to have_no_content(I18n.t('gws/portal.links.manage_portlets'))
      end
    end
  end
end
