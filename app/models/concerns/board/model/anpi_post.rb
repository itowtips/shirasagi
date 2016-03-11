module Board::Model::AnpiPost
  extend ActiveSupport::Concern
  extend SS::Translation
  include SS::Document
  include SS::Reference::Site

  included do
    store_in collection: "board_anpi_posts"

    seqid :id
    # ����
    field :name, type: String
    # �����i���ȁj
    field :kana, type: String
    # �d�b�ԍ�
    field :tel, type: String
    # �Z��
    field :addr, type: String
    # ����
    field :sex, type: String
    # �N��
    field :age, type: Integer
    # ���[���A�h���X
    field :email, type: String
    # ���b�Z�[�W
    field :text, type: String
    # �n�}��̃|�C���g
    field :point, type: Map::Extensions::Point

    permit_params :name, :kana, :tel, :addr, :sex, :age, :email, :text
    permit_params :point
  end

  public
    def sex_options
      %w(male female).map { |m| [ I18n.t("board.options.sex.#{m}"), m ] }.to_a
    end
end
