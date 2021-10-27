class Cms::Line::Poster::Delivery
  include SS::Document
  include SS::Reference::Site
  include SS::Reference::User
  include Pippi::Addon::Member::AdditionalAttributes
  include Cms::SitePermission

  set_permission_name "cms_line_event_sessions", :use

  seqid :id

  field :name, type: String
  field :poster_template, type: String
  field :send_at, type: DateTime
  field :draft, type: Boolean, default: false

  validates :name, presence: true
  validates :poster_template, presence: true

  permit_params :name, :poster_template, :send_at

  def target_members
    Cms::Member.site(cur_site || site).
      where(oauth_type: "line").
      and_enabled.
      in(child_age_situations: child_age_situations)
  end

  def target
    { profile: { userId: target_members.pluck(:oauth_id) } }
  end

  def deliver
    url = "https://poster.ooo/api/v1/message/create"

    headers = {}
    headers["Content-Type"] = "application/json"
    headers["X-POSTER-CLIENT-ID"] = "bf45904c06b9135f8ef4dacce3f2c8363cc48a1f"
    headers["X-POSTER-CLIENT-SECRET"] = "255b87a72936e3f07afc489d3f2795fc1b40e4b30fe7ecc2af32716fdb996a5c94f1ef972e989563"

    body = {}
    body["message_title"] = name
    body["template_id"] = poster_template
    body["target"] = target

    res = Faraday.post(url, body.to_json, headers)
  end

  class << self
    def search(params)
      criteria = all
      return criteria if params.blank?

      if params[:name].present?
        criteria = criteria.search_text params[:name]
      end
      if params[:keyword].present?
        criteria = criteria.keyword_in params[:keyword], :name
      end
      criteria
    end
  end
end
