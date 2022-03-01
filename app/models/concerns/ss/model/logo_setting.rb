module SS::Model::LogoSetting
  extend ActiveSupport::Concern
  extend SS::Translation

  included do
    field :logo_application_name, type: String
    # To support high resolution display like Retina, it needs double size for limitation
    belongs_to_file :logo_application_image, class_name: "SS::LogoFile", resizing: [ 210 * 2, 49 * 2 ]

    field :logo_link_to_type, type: String

    permit_params :logo_application_name, :logo_link_to_type

    validates :logo_application_name, length: { maximum: 24 }
    validates :logo_link_to_type, inclusion: { in: %w(my_page self_site), allow_blank: true }
  end

  def logo_link_to_type_options
    %w(my_page self_site).map do |v|
      [ I18n.t("ss.options.logo_link_to_type.#{v}"), v ]
    end
  end

  def logo_link_to
    case logo_link_to_type
    when "self_site"
      case self
      when SS::Model::Site
        Rails.application.routes.url_helpers.cms_main_path(site: self)
      when SS::Model::Group
        Rails.application.routes.url_helpers.gws_portal_path(site: self)
      else # unknown object
        Rails.application.routes.url_helpers.sns_mypage_path
      end
    else # my_page
      Rails.application.routes.url_helpers.sns_mypage_path
    end
  end
end
