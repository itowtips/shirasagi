require 'spec_helper'

describe 'gws_portal_group_portal', type: :feature, dbscope: :example do
  let(:site) { gws_site }
  let(:user) { gws_user }
  let(:group) { gws_user.groups.first }
  let(:index_path) { gws_portal_group_path(site: site, group: group) }
  let(:portal) { group.find_portal_setting(cur_user: user, cur_site: site).tap(&:save) }
  let(:default_portlets) { SS.config.gws['portal']['group_portlets'] }

  before { create_default_portal }

  context 'with auth' do
    before { login_gws_user }

    it '#index' do
      visit index_path
      default_portlets.each do |data|
        expect(page).to have_css(".portlet-model-#{data['model']}")
      end
      expect(Gws::Portal::GroupPortlet.all.size).to eq(default_portlets.size)

      first('.current-navi a.management').click
      expect(current_path).to eq gws_portal_group_layouts_path(site: site, group: group)
      expect(Gws::Portal::GroupPortlet.all.size).to eq(default_portlets.size)

      # layout
      first('#navi a', text: I18n.t('gws/portal.links.arrange_portlets')).click
      click_button I18n.t('ss.buttons.reset')
      click_button I18n.t('gws/portal.buttons.save_layouts')

      # portlets
      first('#navi a', text: I18n.t('gws/portal.links.manage_portlets')).click
      expect(current_path).to eq gws_portal_group_portlets_path(site: site, group: group)

      first('.list-items a', text: default_portlets.first['name']).click
      first('#menu a', text: I18n.t('ss.links.edit')).click
      click_button I18n.t('ss.buttons.save')

      first('#menu a', text: I18n.t('ss.links.delete')).click
      click_button I18n.t('ss.buttons.delete')
      expect(Gws::Portal::GroupPortlet.all.size).not_to eq(default_portlets.size)

      click_on I18n.t('gws/portal.sync_preset')
      within "form .gws-tabs" do
        click_on I18n.t('ss.buttons.sync')
      end
      within "form footer.send" do
        click_on I18n.t('ss.buttons.sync')
      end
      expect(page).to have_css('#notice', text: I18n.t("ss.notice.synced"))
      expect(Gws::Portal::GroupPortlet.all.size).to eq(default_portlets.size - 1)

      click_on I18n.t('gws/portal.sync_preset')
      within "form .gws-tabs" do
        click_on I18n.t('ss.buttons.initialize')
      end
      within "form footer.send" do
        click_on I18n.t('ss.buttons.initialize')
      end
      expect(page).to have_css('#notice', text: I18n.t("ss.notice.initialized"))
      expect(Gws::Portal::GroupPortlet.all.size).to eq(default_portlets.size)
    end
  end

  context 'with governance mode: only allowed use_gws_portal_organization_settings permission' do
    let(:role) { create(:gws_role_portal_organization_use, permissions: %w(use_gws_board read_private_gws_board_posts)) }
    let!(:user) { create(:gws_user, group_ids: [ site.id ], gws_role_ids: [ role.id ]) }

    before { login_user user }

    it do
      visit gws_portal_path(site: site)
      within ".main-navi" do
        expect(page).to have_css("a.icon-portal[href='/.g#{site.id}']", text: I18n.t('modules.gws/portal'))
        expect(page).to have_no_css("a.icon-portal", text: I18n.t('gws/portal.self_portal'))
        expect(page).to have_no_css("a.icon-portal", text: I18n.t('gws/portal.tabs.root_portal'))
      end
      expect(page).to have_css(".gws-portlets .portlet-model-board", text: I18n.t("gws/portal.portlets.board.name"))

      visit gws_portal_group_path(site: site, group: site)
      within ".main-navi" do
        expect(page).to have_css("a.icon-portal[href='/.g#{site.id}']", text: I18n.t('modules.gws/portal'))
        expect(page).to have_no_css("a.icon-portal", text: I18n.t('gws/portal.self_portal'))
        expect(page).to have_no_css("a.icon-portal", text: I18n.t('gws/portal.tabs.root_portal'))
      end
      expect(page).to have_css(".gws-portlets .portlet-model-board", text: I18n.t("gws/portal.portlets.board.name"))
    end
  end
end
