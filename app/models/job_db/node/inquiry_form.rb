class JobDb::Node::InquiryForm
  include Cms::Model::Node
  include Cms::Addon::NodeSetting
  include Cms::Addon::Meta
  include Inquiry::Addon::Message
  include Inquiry::Addon::Captcha
  include Inquiry::Addon::Notice
  include Inquiry::Addon::Reply
  include Inquiry::Addon::ReleasePlan
  include Inquiry::Addon::ReceptionPlan
  include Inquiry::Addon::Aggregation
  include Cms::Addon::Release
  include Cms::Addon::GroupPermission
  include History::Addon::Backup

  default_scope ->{ where(route: "job_db/inquiry_form") }
end
