FactoryGirl.define do
  factory :schedule_plan, class: Schedule::Plan do
    name 'schedule-#{unique_id}'
    text 'text-#{unique_id}'
    start_at Time.zone.local(2015, 4, 1, 0, 0)
    end_at Time.zone.local(2015, 4, 1, 0, 1)
    allday false
  end
end
