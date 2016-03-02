class Member::Group
  extend SS::Translation
  include SS::Document
  include SS::Reference::Site
  include Cms::SitePermission

  set_permission_name :cms_users, :edit

  seqid :id, init: 100
  field :name, type: String
  field :invitation_message, type: String
  embeds_many :members, class_name: "Member::GroupMember", cascade_callbacks: true

  attr_accessor :cur_node
  attr_accessor :in_admin
  attr_accessor :in_invitees
  attr_accessor :in_remove_member_ids

  permit_params :name, :invitation_message, :in_admin, :in_invitees
  permit_params in_remove_member_ids: []

  before_validation :set_admin_member
  before_validation :set_invitees
  validate :remove_members
  validate :validate_admin
  after_save :send_invitations
  after_save :clear_context

  class << self
    def search(params = {})
      criteria = self.where({})
      return criteria if params.blank?

      if params[:name].present?
        criteria = criteria.search_text params[:name]
      end
      if params[:keyword].present?
        criteria = criteria.keyword_in params[:keyword], :name
      end
      criteria
    end

    def and_member(member)
      self.where(members: { '$elemMatch' => { member_id: member.id, state: { '$in' => ['admin', 'user'] } } })
    end

    def and_invited(member)
      self.where(members: { '$elemMatch' => { member_id: member.id, state: 'inviting' } })
    end
  end

  def enabled_members
    members.where(state: { '$in' => ['admin', 'user'] }).map(&:member)
  end

  def admin_member?(member)
    members.where(member_id: member.id, state: 'admin').present?
  end

  def accept(member)
    member = members.where(member_id: member.id, state: 'inviting').first
    return true if member.blank?

    member.state = 'user'
    self.save
  end

  def reject(member)
    member = members.where(member_id: member.id, state: 'inviting').first
    return true if member.blank?

    member.state = 'rejected'
    self.save
  end

  private
    def set_admin_member
      if in_admin.is_a?(String) || in_admin.is_a?(Fixnum)
        self.in_admin = Cms::Member.site(site || @cur_site).where(id: in_admin).first
      end
      return if in_admin.blank?

      group_member = self.members.where(member_id: in_admin.id).first
      if group_member.present?
        group_member.state = 'admin'
      else
        self.members.new(member_id: in_admin.id, state: 'admin')
      end
    end

    def validate_admin
      has_admin = self.members.where(state: 'admin').map(&:member).compact.present?
      errors.add :base, '管理者が設定されていません。' unless has_admin
    end

    def set_invitees
      @to_be_sent_invitations ||= []
      return if in_invitees.blank?

      in_invitees.split(/\r\n|\n/).each do |email|
        unless Cms::Member::EMAIL_REGEX =~ email
          errors.add :base, "#{email} は不正です。"
          next
        end

        member = find_or_create_member(email)
        if member.invalid?
          member.errors.full_messages.each do |msg|
            errors.add :base, msg
          end
          next
        end

        # already registered
        next if self.members.where(member_id: member.id, :state.in => %w(admin user)).present?

        group_member = self.members.where(member_id: member.id, :state.in => %w(inviting rejected)).first
        if group_member.present?
          group_member.state = 'inviting'
          group_member.save
        else
          group_member = self.members.new(member_id: member.id, state: 'inviting')
        end

        if group_member.valid?
          @to_be_sent_invitations << member
        end
      end
      @to_be_sent_invitations.uniq!
    end

    def find_or_create_member(email)
      member = Cms::Member.site(self.site || @cur_site).where(email: email).first
      return member if member.present?

      member = Cms::Member.new(cur_site: self.site || @cur_site, email: email, state: 'temporary')
      member.save
      member
    end

    def remove_members
      return if in_remove_member_ids.blank?

      in_remove_member_ids.each do |member_id|
        if last_admin?(member_id)
          errors.add :base, "管理者が設定されていません。"
          next
        end
        members.where(member_id: member_id).destroy
      end
    end

    def last_admin?(member_id)
      member_id = Integer(member_id) if member_id.is_a?(String)
      admins = members.where(state: 'admin')
      admins.count == 1 && admins.first.member_id == member_id
    end

    def send_invitations
      return if @to_be_sent_invitations.blank?

      @to_be_sent_invitations.each do |member|
        if member.state == 'temporary'
          Member::Mailer.member_invitation_mail(invitation_message, member, @cur_node).deliver_now
        else
          Member::Mailer.group_invitation_mail(invitation_message, member, @cur_node).deliver_now
        end
      end
      @to_be_sent_invitations = nil
    end

    def clear_context
      self.in_admin = nil
      self.in_invitees = nil
      self.in_remove_member_ids = nil
      @to_be_sent_invitations = nil
    end
end
