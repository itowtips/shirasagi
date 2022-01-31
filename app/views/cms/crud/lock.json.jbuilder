# #json.extract! @item, :name, :price, :created_at, :updated_at
# json.extract! *([@item] + @model.fields.keys.map {|m| m.to_sym })
json._id @item._id
json.lock_owner @item.lock_owner.try(:long_name)
json.lock_owner_id @item.lock_owner_id
epoch = @item.lock_until.try(:to_i)
json.lock_until_epoch epoch
pretty = @item.lock_until.try { |time| I18n.l(time, format: :picker) }
json.lock_until_pretty pretty
