module JobDb::Addon::Company::SeniorMessage
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    field :job_challenging, type: String #仕事のやりがい
    field :up_and_coming_recruit, type: String #求める人材

    belongs_to_file :senior_image #先輩イメージ
    field :senior_image_caption, type: String #先輩イメージ キャプション

    field :senior_name, type: String #先輩氏名
    field :senior_year_of_employment, type: String #先輩入社年度

    permit_params :job_challenging
    permit_params :up_and_coming_recruit
    permit_params :in_senior_image
    permit_params :senior_image_caption

    permit_params :senior_name
    permit_params :senior_year_of_employment
  end
end
