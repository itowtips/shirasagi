require 'spec_helper'

describe Gws::Portal::SyncPresetJob, dbscope: :example do
  let!(:site) { gws_site }
  let!(:user) { gws_user }

  let!(:group1) { create :gws_group, name: "#{site.name}/#{unique_id}" }
  let!(:group2) { create :gws_group, name: "#{site.name}/#{unique_id}" }

  let!(:user1) { create :gws_user, group_ids: [group1.id] }
  let!(:user2) { create :gws_user, group_ids: [group1.id] }
  let!(:user3) { create :gws_user, group_ids: [group2.id] }
  let!(:user4) { create :gws_user, group_ids: [group2.id] }

  let(:user_portlets) { %w(schedule presence faq qna board monitor circular reminder) }
  let(:group_portlets) { %w(schedule monitor board faq qna) }

  before { create_default_portal }

  context "sync" do
    it do
      expect(Gws::Portal::UserSetting.count).to eq 0
      expect(Gws::Portal::UserPortlet.count).to eq 0

      expect(Gws::Portal::GroupSetting.count).to eq 0
      expect(Gws::Portal::GroupPortlet.count).to eq 0

      described_class.bind(site_id: site.id).perform_now

      expect(Gws::Portal::UserSetting.count).to eq Gws::User.all.size
      expect(Gws::Portal::GroupSetting.count).to eq Gws::Group.all.size

      Gws::User.each do |target|
        setting = target.find_portal_setting(cur_user: user, cur_site: site)
        expect(setting.portlets.size).to eq 0
      end
      Gws::Group.each do |target|
        setting = target.find_portal_setting(cur_user: user, cur_site: site)
        expect(setting.portlets.size).to eq 0
      end
    end
  end

  context "reset" do
    it do
      expect(Gws::Portal::UserSetting.count).to eq 0
      expect(Gws::Portal::UserPortlet.count).to eq 0

      expect(Gws::Portal::GroupSetting.count).to eq 0
      expect(Gws::Portal::GroupPortlet.count).to eq 0

      described_class.bind(site_id: site.id).perform_now(action: :reset)

      expect(Gws::Portal::UserSetting.count).to eq Gws::User.all.size
      expect(Gws::Portal::GroupSetting.count).to eq Gws::Group.all.size

      Gws::User.each do |target|
        setting = target.find_portal_setting(cur_user: user, cur_site: site)
        expect(setting.portlets.map(&:portlet_model)).to match_array user_portlets
      end
      Gws::Group.each do |target|
        setting = target.find_portal_setting(cur_user: user, cur_site: site)
        expect(setting.portlets.map(&:portlet_model)).to match_array group_portlets
      end
    end
  end
end
