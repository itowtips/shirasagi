require 'spec_helper'

describe Gws::Portal::Preset, type: :model, dbscope: :example do
  let!(:site) { gws_site }
  let!(:user) { gws_user }

  let!(:group) { create :gws_group, name: "#{site.name}/#{unique_id}" }
  let!(:user1) { create :gws_user, group_ids: [group.id] }
  let!(:user2) { create :gws_user, group_ids: [group.id] }

  let!(:preset) { create(:gws_portal_preset, name: "user", portal_type: "user") }

  # managed ad portlet
  let!(:ad_file) { create :ss_link_file, user_id: gws_user.id }
  let!(:ad) do
    create(:gws_portal_preset_portlet,
      name: "ad",
      portlet_model: "ad",
      setting: preset.portal_setting,
      managed: "managed",
      required: "required",
      show_default: "show",
      description: unique_id,
      order: 20,
      ad_width: 1000,
      ad_speed: 30,
      ad_pause: 60,
      ad_file_ids: [ad_file.id])
  end

  context "#synchronize_portal" do
    it do
      expect(Gws::Portal::UserSetting.count).to eq 0
      expect(Gws::Portal::UserPortlet.count).to eq 0

      user1_setting = user1.find_portal_setting(cur_user: user, cur_site: site)
      user2_setting = user2.find_portal_setting(cur_user: user, cur_site: site)
      user1_setting.save!
      user2_setting.save!

      expect(Gws::Portal::UserSetting.count).to eq 2
      expect(Gws::Portal::UserPortlet.count).to eq 0

      # first synchronize
      preset_setting = preset.portal_setting
      user1_setting.synchronize_portal(preset_setting)
      user2_setting.synchronize_portal(preset_setting)

      user1_setting.reload
      user2_setting.reload
      preset_setting.reload

      expect(user1_setting.portlets.size).to eq 1
      expect(user2_setting.portlets.size).to eq 1

      user1_ad = user1_setting.portlets.find_by(name: ad.name)
      user2_ad = user2_setting.portlets.find_by(name: ad.name)
      first_file_ids = (ad.ad_file_ids + user1_ad.ad_file_ids + user2_ad.ad_file_ids).uniq

      ## 複製されたファイルが存在しなければならない
      expect(user1_ad.ad_files.size).to eq 1
      expect(user2_ad.ad_files.size).to eq 1
      ## ファイルが重複してはならない
      expect(first_file_ids.size).to eq 3

      # second synchronize (not modified)
      user1_setting.synchronize_portal(preset_setting)
      user2_setting.synchronize_portal(preset_setting)

      user1_setting.reload
      user2_setting.reload
      preset_setting.reload

      user1_ad = user1_setting.portlets.find_by(name: ad.name)
      user2_ad = user2_setting.portlets.find_by(name: ad.name)
      second_file_ids = (ad.ad_file_ids + user1_ad.ad_file_ids + user2_ad.ad_file_ids).uniq

      ## 複製されたファイルが存在しなければならない
      expect(user1_ad.ad_files.size).to eq 1
      expect(user2_ad.ad_files.size).to eq 1
      ## ファイルが重複してはならない
      expect(second_file_ids.size).to eq 3
      ## 内容を変更していないので、ファイルは変更されない
      expect(second_file_ids).to match_array first_file_ids

      # third synchronize (modified)
      ad.ad_width = 300
      ad.save
      ad.reload

      user1_setting.synchronize_portal(preset_setting)
      user2_setting.synchronize_portal(preset_setting)

      user1_setting.reload
      user2_setting.reload
      preset_setting.reload

      user1_ad = user1_setting.portlets.find_by(name: ad.name)
      user2_ad = user2_setting.portlets.find_by(name: ad.name)
      third_file_ids = (ad.ad_file_ids + user1_ad.ad_file_ids + user2_ad.ad_file_ids).uniq

      ## 複製されたファイルが存在しなければならない
      expect(user1_ad.ad_files.size).to eq 1
      expect(user2_ad.ad_files.size).to eq 1
      ## ファイルが重複してはならない
      expect(third_file_ids.size).to eq 3
      ## 内容を変更したので、ファイルは更新されなければならない
      expect(third_file_ids).not_to match_array second_file_ids
      ## 変更されたファイルは削除されていなければならない
      #expect(SS::File.in(id: second_file_ids).size).to be 0
    end
  end
end
