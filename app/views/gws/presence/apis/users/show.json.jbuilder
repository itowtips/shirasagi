json.items do
  json.array!(@items) do |item|
    user_presence = item.user_presence(@cur_site) || Gws::UserPresence.new

    json.id item.id
    json.name item.name
    json.presence_state user_presence.state
    json.presence_state_label (user_presence.label :state)
    json.presence_plan user_presence.plan
    json.presence_memo user_presence.memo
    json.editable @editable_user_ids.include?(item.id)
    json.manageable @manageable
  end
end