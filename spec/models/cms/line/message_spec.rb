require 'spec_helper'

describe Cms::Line::Message, type: :model, dbscope: :example do
  let!(:today) { Time.zone.today }
  let!(:in_birth1) { { era: "seireki", year: (today.year - 1), month: today.month, day: today.day } }
  let!(:in_birth2) { { era: "seireki", year: (today.year - 3), month: today.month, day: today.day } }
  let!(:in_birth3) { { era: "seireki", year: (today.year - 5), month: today.month, day: today.day } }

  # active members
  let!(:member1) { create(:cms_line_member) }
  let!(:member2) { create(:cms_line_member, in_child1_birth: in_birth1) }
  let!(:member3) { create(:cms_line_member, residence_areas: %w(nakaku)) }
  let!(:member4) { create(:cms_line_member, in_child1_birth: in_birth2, in_child2_birth: in_birth3) }
  let!(:member5) { create(:cms_line_member, residence_areas: %w(higashiku)) }
  let!(:member6) { create(:cms_line_member, in_child1_birth: in_birth1, in_child2_birth: in_birth2, residence_areas: %w(nakaku higashiku)) }

  # expired members
  let!(:member7) { create(:cms_member, subscribe_line_message: "active") }
  let!(:member8) { create(:cms_line_member, subscribe_line_message: "expired") }
  let!(:member9) { create(:cms_line_member, subscribe_line_message: "active", state: "disabled") }

  def member_ids
    item.extract_deliver_members.map(&:id)
  end

  describe "members condition" do
    let!(:item) { create :cms_line_message_input_condition }

    it do
      expect(member_ids).to match_array [member2.id, member6.id]
    end
  end

  describe "members condition1" do
    let!(:item) { create :cms_line_message_input_condition1 }

    it do
      expect(member_ids).to match_array [member4.id, member6.id]
    end
  end

  describe "members condition2" do
    let!(:item) { create :cms_line_message_input_condition3 }

    it do
      expect(member_ids).to match_array [member3.id, member6.id]
    end
  end

  describe "members condition3" do
    let!(:item) { create :cms_line_message_input_condition_invalid }

    it do
      expect(member_ids).to match_array [member6.id]
    end
  end

  describe "validation" do
    it do
      item = build(:cms_line_deliver_condition_invalid)
      expect(item.valid?).to be_falsey
    end
  end
end
