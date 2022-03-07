require 'spec_helper'

describe Gws::Portal::Preset, type: :model, dbscope: :example do
  let!(:site) { gws_site }
  let!(:group1) { create :gws_group, name: "#{site.name}/#{unique_id}" }
  let!(:group2) { create :gws_group, name: "#{site.name}/#{unique_id}" }

  let!(:user1) { create :gws_user, group_ids: [group1.id] }
  let!(:user2) { create :gws_user, group_ids: [group1.id] }
  let!(:user3) { create :gws_user, group_ids: [group2.id] }
  let!(:user4) { create :gws_user, group_ids: [group2.id] }

  context "#find_portal_preset" do
    context "no presets" do
      it do
        expect(described_class.find_portal_preset(site, site)).to be nil
        expect(described_class.find_portal_preset(site, group1)).to be nil
        expect(described_class.find_portal_preset(site, group2)).to be nil
        expect(described_class.find_portal_preset(site, user1)).to be nil
        expect(described_class.find_portal_preset(site, user2)).to be nil
        expect(described_class.find_portal_preset(site, user3)).to be nil
        expect(described_class.find_portal_preset(site, user4)).to be nil
      end
    end

    context "default presets" do
      let!(:preset_user) { create(:gws_portal_preset, name: "user", portal_type: "user") }
      let!(:preset_group) { create(:gws_portal_preset, name: "group", portal_type: "group") }
      let!(:preset_organization) { create(:gws_portal_preset, name: "organization", portal_type: "organization") }

      it do
        expect(described_class.find_portal_preset(site, site).id).to be preset_organization.id
        expect(described_class.find_portal_preset(site, group1).id).to be preset_group.id
        expect(described_class.find_portal_preset(site, group2).id).to be preset_group.id
        expect(described_class.find_portal_preset(site, user1).id).to be preset_user.id
        expect(described_class.find_portal_preset(site, user2).id).to be preset_user.id
        expect(described_class.find_portal_preset(site, user3).id).to be preset_user.id
        expect(described_class.find_portal_preset(site, user4).id).to be preset_user.id
      end
    end

    context "targeted members" do
      let!(:preset_user1) do
        create(:gws_portal_preset, name: "user", portal_type: "user", order: 10,
          member_ids: [user1.id, user2.id])
      end
      let!(:preset_user2) do
        create(:gws_portal_preset, name: "user", portal_type: "user", order: 20,
          member_ids: [user2.id, user3.id, user4.id])
      end

      it do
        expect(described_class.find_portal_preset(site, site)).to be nil
        expect(described_class.find_portal_preset(site, group1)).to be nil
        expect(described_class.find_portal_preset(site, group2)).to be nil
        expect(described_class.find_portal_preset(site, user1).id).to be preset_user1.id
        expect(described_class.find_portal_preset(site, user2).id).to be preset_user1.id
        expect(described_class.find_portal_preset(site, user3).id).to be preset_user2.id
        expect(described_class.find_portal_preset(site, user4).id).to be preset_user2.id
      end
    end

    context "targeted member groups" do
      let!(:preset_user1) do
        create(:gws_portal_preset, name: "user", portal_type: "user", order: 10,
          member_group_ids: [group1.id])
      end
      let!(:preset_user2) do
        create(:gws_portal_preset, name: "user", portal_type: "user", order: 20,
          member_ids: [user1.id])
      end
      let!(:preset_group) do
        create(:gws_portal_preset, name: "user", portal_type: "group", order: 30,
        member_group_ids: [group1.id])
      end

      it do
        expect(described_class.find_portal_preset(site, site)).to be nil
        expect(described_class.find_portal_preset(site, group1).id).to be preset_group.id
        expect(described_class.find_portal_preset(site, group2)).to be nil
        expect(described_class.find_portal_preset(site, user1).id).to be preset_user2.id
        expect(described_class.find_portal_preset(site, user2).id).to be preset_user1.id
      end
    end
  end
end
