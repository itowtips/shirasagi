module JobDb::Addon::Company::Inquiry
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    field :human_resources_representative_position, type: String #人事担当 職名
    field :human_resources_representative_name, type: String #人事担当 氏名
    field :inquiry_tel, type: String #人事担当　電話番号
    field :inquiry_fax, type: String #人事担当　FAX
    field :inquiry_email, type: String #人事担当　E-MAIL
    field :recruitment_method, type: String #募集方法
    field :application_document, type: String #応募書類
    field :screening_method, type: String #選考方法

    validate :validate_inquiry_tel
    validate :validate_inquiry_fax

    permit_params :human_resources_representative_position
    permit_params :human_resources_representative_name
    permit_params :inquiry_tel
    permit_params :inquiry_fax
    permit_params :inquiry_email
    permit_params :recruitment_method
    permit_params :application_document
    permit_params :screening_method
  end

  def validate_inquiry_tel
    return if inquiry_tel.blank?

    if inquiry_tel !~ /^\d+$/
      errors.add :inquiry_tel, "は数値で入力してください。"
      return
    end
  end

  def validate_inquiry_fax
    return if inquiry_fax.blank?

    if inquiry_fax !~ /^\d+$/
      errors.add :inquiry_fax, "は数値で入力してください。"
      return
    end
  end
end
