module JobDb::Addon::Company::GuideAuthor
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    field :guide_author_created, type: DateTime #企業ガイド 原稿提出日
    field :guide_author_name, type: String #企業ガイド 氏名
    field :guide_author_position, type: String #企業ガイド 職名
    field :guide_author_tel, type: String #企業ガイド 電話番号
    field :guide_author_email, type: String #企業ガイド E-MAIL

    permit_params :guide_author_created
    permit_params :guide_author_name
    permit_params :guide_author_position
    permit_params :guide_author_tel
    permit_params :guide_author_email
  end
end
