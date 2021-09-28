FactoryBot.define do
  factory :cms_line_message, class: Cms::Line::Message do
    site { cms_site }
    name { unique_id }
  end

  factory :cms_line_message_input_condition, class: Cms::Line::Message do
    site { cms_site }
    name { unique_id }
    deliver_condition_state { "multicast_with_input_condition" }
    lower_year1 { 1 }
    upper_year1 { 1 }
  end

  factory :cms_line_message_input_condition1, class: Cms::Line::Message do
    site { cms_site }
    name { unique_id }
    deliver_condition_state { "multicast_with_input_condition" }
    lower_year1 { 2 }
    upper_year1 { 3 }
  end

  #factory :cms_line_message_input_condition2, class: Cms::Line::Message do
  #  site { cms_site }
  #  name { unique_id }
  #  deliver_condition_state { "multicast_with_input_condition" }
  #  residence_areas { %w(nakaku) }
  #end

  #factory :cms_line_message_input_condition3, class: Cms::Line::Message do
  #  site { cms_site }
  #  name { unique_id }
  #  deliver_condition_state { "multicast_with_input_condition" }
  #  lower_year1 { 3 }
  #  upper_year1 { 4 }
  #  residence_areas { %w(nakaku higashiku) }
  #end

  factory :cms_line_message_input_condition_invalid, class: Cms::Line::Message do
    site { cms_site }
    name { unique_id }
    deliver_condition_state { "multicast_with_input_condition" }
  end
end
