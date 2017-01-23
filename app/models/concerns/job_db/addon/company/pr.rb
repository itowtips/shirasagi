module JobDb::Addon::Company::Pr
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    field :office_introduction, type: String #事業所紹介

    belongs_to_file :office_introduction_image #事業所イメージ
    field :office_introduction_image_caption, type: String #事業所イメージ キャプション

    field :pr_point, type: String #注目ポイント
    belongs_to_file :pr_image_1 #PRイメージ１
    field :pr_image_1_caption, type: String #PRイメージ１ キャプション

    belongs_to_file :pr_image_2 #PRイメージ２
    field :pr_image_2_caption, type: String #PRイメージ２ キャプション

    belongs_to_file :pr_image_3 #PRイメージ３
    field :pr_image_3_caption, type: String #PRイメージ３ キャプション

    permit_params :office_introduction
    permit_params :in_office_introduction_image
    permit_params :office_introduction_image_caption

    permit_params :pr_point
    permit_params :in_pr_image_1
    permit_params :pr_image_1_caption
    permit_params :in_pr_image_2
    permit_params :pr_image_2_caption
    permit_params :in_pr_image_3
    permit_params :pr_image_3_caption
  end
end
