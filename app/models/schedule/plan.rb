class Schedule::Plan
  include Schedule::Planable
  include SS::Reference::User
  include Gws::Addon::GroupPermission

  #TODO: 繰り返しのデータの持ち方については、要検討
  belongs_to :repeat, class_name: 'Schedule::PlanRepeat'

  has_and_belongs_to_many :users, class_name: 'SS::User'

  #TODO: 設備予約
  #TODO: 公開範囲
  #TODO: 編集権限

  #TODO: 繰り返しのバリデーションを書く
  #TODO: 設備予約のバリデーションを書く
  #TODO: 公開範囲のバリデーションを書く
  #TODO: 編集権限のバリデーションを書く
end
