require 'spec_helper'

describe Member::Group, dbscope: :example do
  let(:site) { cms_site }
  let(:admin_member) { create(:cms_member) }
  let(:name) { unique_id }
  let(:invitation_message) { unique_id }
  let(:node) { create(:member_node_my_group) }

  describe 'create' do
    context 'usual case' do
      subject do
        described_class.create(
          cur_site: site,
          cur_node: node,
          name: name,
          invitation_message: invitation_message,
          in_admin: admin_member)
      end

      its(:valid?) { is_expected.to be_truthy }
      its(:name) { is_expected.to eq name }
      its(:invitation_message) { is_expected.to eq invitation_message }
      it 'members' do
        expect(subject.members.count).to eq 1
        expect(subject.members.first.member_id).to eq admin_member.id
        expect(subject.members.first.state).to eq 'admin'
      end
    end

    context 'no admin' do
      subject do
        described_class.create(cur_site: site, cur_node: node, name: name, invitation_message: invitation_message)
      end

      its(:invalid?) { is_expected.to be_truthy }
      it 'errors' do
        expect(subject.errors.count).to eq 1
        expect(subject.errors.full_messages.first).to eq '管理者が設定されていません。'
      end
    end
  end

  describe 'update' do
    context 'add a existing member (= invite a existing member)' do
      let(:member1) { create(:cms_member) }
      subject do
        described_class.create(
          cur_site: site,
          cur_node: node,
          name: name,
          invitation_message: invitation_message,
          in_admin: admin_member)
      end

      before do
        subject.in_invitees = member1.email
        subject.save
      end

      its(:valid?) { is_expected.to be_truthy }
      its(:name) { is_expected.to eq name }
      its(:invitation_message) { is_expected.to eq invitation_message }
      it 'members' do
        expect(subject.members.count).to eq 2
        expect(subject.members.last.member_id).to eq member1.id
        expect(subject.members.last.state).to eq 'inviting'
      end
    end

    context 'add a new member (= invite a new member)' do
      let(:email) { "#{unique_id}@example.jp" }
      subject do
        described_class.create(
          cur_site: site, cur_node: node,
          name: name, invitation_message: invitation_message,
          in_admin: admin_member)
      end

      before do
        subject.in_invitees = email
        subject.save
      end

      it 'members' do
        member1 = Cms::Member.site(site).where(email: email).first
        expect(member1).not_to be_nil
        expect(member1.state).to eq 'temporary'
        expect(subject.members.count).to eq 2
        expect(subject.members.last.member_id).to eq member1.id
        expect(subject.members.last.state).to eq 'inviting'
      end
    end
  end

  describe 'delete' do
    context 'delete regular user' do
      let(:member1) { create(:cms_member) }
      subject do
        described_class.create(
          cur_site: site,
          cur_node: node,
          name: name,
          invitation_message: invitation_message,
          in_admin: admin_member, in_invitees: member1.email)
      end

      before do
        group_member = subject.members.find_by(member_id: member1.id)
        subject.in_remove_member_ids = [group_member.member_id]
        subject.save
      end

      its(:valid?) { is_expected.to be_truthy }
      its(:name) { is_expected.to eq name }
      its(:invitation_message) { is_expected.to eq invitation_message }
      it 'members' do
        expect(subject.members.count).to eq 1
        expect(subject.members.first.member_id).to eq admin_member.id
        expect(subject.members.first.state).to eq 'admin'
      end
    end

    context 'delete admin, this is expected to be an error' do
      let(:member1) { create(:cms_member) }
      subject do
        described_class.create(
          cur_site: site,
          cur_node: node,
          name: name,
          invitation_message: invitation_message,
          in_admin: admin_member, in_invitees: member1.email)
      end

      before do
        group_member = subject.members.find_by(member_id: admin_member.id)
        subject.in_remove_member_ids = [group_member.member_id]
        subject.save
      end

      its(:invalid?) { is_expected.to be_truthy }
      its(:name) { is_expected.to eq name }
      its(:invitation_message) { is_expected.to eq invitation_message }
      it 'members' do
        expect(subject.members.count).to eq 2
        expect(subject.members.first.member_id).to eq admin_member.id
        expect(subject.members.first.state).to eq 'admin'
        expect(subject.members.last.member_id).to eq member1.id
        expect(subject.members.last.state).to eq 'inviting'
      end
    end
  end
end
