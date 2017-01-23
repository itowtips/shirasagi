module JobDb::Addon::Company::Data
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    field :representative_position, type: String #代表者 職名
    field :representative_name, type: String #代表者 氏名

    field :postal_code, type: String #住所　郵便番号
    field :address_1 #住所　市区町村
    field :address_2 #住所　番地以降
    field :address_3 #住所　マンション名
    field :address_tel #住所 電話番号
    field :address_fax #住所 FAX
    field :address_email #住所 E-MAIL
    field :address_related_url #住所 ホームページ

    field :founding_year, type: String #創業
    field :annual_sales, type: String #年商
    field :capital, type: String #資本金
    field :number_of_employees, type: String #従業員数
    field :branch_office, type: String #支社・支店・営業所等
    field :job_category, type: String #職種
    field :working_hours, type: String #勤務時間
    field :holiday, type: String #休日・休暇
    field :starting_salary, type: String #初任給
    field :allowances, type: String #諸手当
    field :pay_rise, type: String #昇給
    field :bonus, type: String #賞与
    field :retirement_age, type: String #定年
    field :severance_pay, type: String #退職金
    field :welfare, type: String #福利厚生
    field :training_system, type: String #研修制度
    field :new_graduate_employment, type: String #新卒採用実績
    field :new_graduate_employment_school, type: String #新卒採用学校

    permit_params :representative_position
    permit_params :representative_name

    permit_params :postal_code
    permit_params :address_1
    permit_params :address_2
    permit_params :address_3
    permit_params :address_tel
    permit_params :address_fax
    permit_params :address_email
    permit_params :address_related_url

    permit_params :founding_year
    permit_params :annual_sales
    permit_params :capital
    permit_params :number_of_employees
    permit_params :branch_office
    permit_params :job_category
    permit_params :working_hours
    permit_params :holiday
    permit_params :starting_salary
    permit_params :allowances
    permit_params :pay_rise
    permit_params :bonus
    permit_params :retirement_age
    permit_params :severance_pay
    permit_params :welfare
    permit_params :training_system
    permit_params :new_graduate_employment
    permit_params :new_graduate_employment_school

    before_validation :normalize_postal_code
    validate :validate_postal_code
    validate :validate_address_tel
    validate :validate_address_fax
  end

  def normalize_postal_code
    return if postal_code.blank?
    self.postal_code = postal_code.tr('０-９ａ-ｚＡ-Ｚー－～', '0-9a-zA-Z---')
  end

  def validate_postal_code
    return if postal_code.blank?

    if postal_code !~ /^\d{7}$/
      errors.add :postal_code, "は数値７桁で入力してください。"
      return
    end
  end

  def validate_address_tel
    return if address_tel.blank?

    if address_tel !~ /^\d+$/
      errors.add :address_tel, "は数値で入力してください。"
      return
    end
  end

  def validate_address_fax
    return if address_fax.blank?

    if address_fax !~ /^\d+$/
      errors.add :address_fax, "は数値で入力してください。"
      return
    end
  end
end
