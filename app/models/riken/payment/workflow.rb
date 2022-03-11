module Riken::Payment
  class Workflow
    include ActiveModel::Model

    attr_reader :setting, :site, :workflow, :item, :member
    attr_reader :user, :request_title, :remand_title, :category
    attr_reader :id, :proxy_id, :create_id, :update_time, :status

    validate :validate_setting
    validate :validate_workflow
    validate :validate_member

    public

    def initialize(setting, workflow)
      @setting = setting
      @site = setting.site
      @workflow = workflow
      @user = setting.circular_owner
      @request_title = setting.request_title
      @remand_title = setting.remand_title
      @category = setting.circular_category
    end

    def model
      Gws::Circular::Post
    end

    def save_circular_post
      return false unless valid?
      item.cur_site = site
      item.cur_user = user
      item.due_date = (Time.zone.today + 7)
      item.member_ids = [member.id]
      item.user_ids = [user.id, member.id]
      item.riken_workflow_update_time = update_time
      item.state = "public"
      item.text_type = "cke"
      item.category_ids = [category.id] if category

      if status == "0"
        item.name = request_title
        item.text = I18n.t("riken.payment.request_message",
          delegation_start_date: format_workflow_date(workflow.delegation_start_date),
          delegation_end_date: format_workflow_date(workflow.delegation_end_date),
          create_name: workflow.create_name,
          proxy_name: workflow.proxy_name,
          authorizer_name: workflow.authorizer_name,
          url: workflow.url)
      else
        item.name = remand_title
        item.text = I18n.t("riken.payment.remand_message",
          delegation_start_date: format_workflow_date(workflow.delegation_start_date),
          delegation_end_date: format_workflow_date(workflow.delegation_end_date),
          create_name: workflow.create_name,
          proxy_name: workflow.proxy_name,
          authorizer_name: workflow.authorizer_name,
          url: workflow.url)
      end
      if item.save
        true
      else
        item.errors.each { |error| self.errors.add :base, error.message }
        false
      end
    end

    private

    def validate_setting
      self.errors.add :site, :blank if site.nil?
      self.errors.add :user, :blank if user.nil?
      self.errors.add :request_title, :blank if request_title.blank?
      self.errors.add :remand_title, :blank if remand_title.blank?
    end

    def validate_workflow
      return if errors.present?

      if workflow.blank?
        self.errors.add :workflow, :blank
        return
      end

      @id = workflow.id
      @proxy_id = workflow.proxy_id
      @create_id = workflow.create_id
      @update_time = workflow.update_time
      @status = workflow.status

      self.errors.add :id, :blank if id.blank?
      self.errors.add :update_time, :blank if update_time.blank?
      self.errors.add :status, :invalid if status != "0" && workflow.status != "1"
    end

    def validate_member
      return if errors.present?

      @item = model.find_or_initialize_by(
        site_id: site.id,
        riken_workflow_id: id,
        riken_workflow_status: status,
        riken_workflow_update_time: update_time)

      if item.persisted?
        # 既に登録済みならインポートしない
        self.errors.add :base, "既に登録済み(update_time:#{update_time})"
        return
      end

      if status == "0"
        riken_id = Riken.encrypt(proxy_id)
        @member = Gws::User.where(uid: riken_id).first
        # 通知対象（代理決裁者）メンバーが見つからない
        self.errors.add :base, "通知対象のメンバーが見つからない(proxy_id:#{proxy_id})" if member.nil?
      else
        riken_id = Riken.encrypt(create_id)
        @member = Gws::User.where(uid: riken_id).first
        # 通知対象（申請者）メンバーが見つからない
        self.errors.add :base, "通知対象のメンバーが見つからない(create_id:#{create_id})" if member.nil?
      end
    end

    def format_workflow_date(date)
      Time.zone.parse(date).to_date.strftime("%Y/%m/%d")
    end
  end
end
