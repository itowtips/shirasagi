FactoryBot.define do
  factory :cms_line_deliver_condition, class: Cms::Line::DeliverCondition do
    site { cms_site }
    name { unique_id }
    lower_year1 { 1 }
    upper_year1 { 1 }
  end

  factory :cms_line_deliver_condition1, class: Cms::Line::DeliverCondition do
    site { cms_site }
    name { unique_id }
    lower_year1 { 2 }
    upper_year1 { 3 }
  end

  #factory :cms_line_deliver_condition2, class: Cms::Line::DeliverCondition do
  #  site { cms_site }
  #  name { unique_id }
  #  residence_areas { %w(nakaku) }
  #end

  #factory :cms_line_deliver_condition3, class: Cms::Line::DeliverCondition do
  #  site { cms_site }
  #  name { unique_id }
  #  lower_year1 { 3 }
  #  upper_year1 { 4 }
  #  residence_areas { %w(nakaku higashiku) }
  #end

  factory :cms_line_deliver_condition_invalid, class: Cms::Line::DeliverCondition do
    site { cms_site }
    name { unique_id }
  end
end
