FactoryBot.define do
  factory :gws_portal_preset_portlet, class: Gws::Portal::PresetPortlet, traits: [:gws_portal_portlet_base] do
    portlet_model { '' }
  end

=begin
  trait :gws_portal_preset_free_portlet do
    portlet_model { "free" }
  end

  trait :gws_portal_preset_links_portlet do
    portlet_model { "links" }
  end

  trait :gws_portal_preset_reminder_portlet do
    portlet_model { "reminder" }
  end

  trait :gws_portal_preset_schedule_portlet do
    portlet_model { "schedule" }
  end

  trait :gws_portal_preset_todo_portlet do
    portlet_model { "todo" }
  end

  trait :gws_portal_preset_bookmark_portlet do
    portlet_model { "bookmark" }
  end

  trait :gws_portal_preset_report_portlet do
    portlet_model { "report" }
  end

  trait :gws_portal_preset_workflow_portlet do
    portlet_model { "workflow" }
  end

  trait :gws_portal_preset_circular_portlet do
    portlet_model { "circular" }
  end

  trait :gws_portal_preset_monitor_portlet do
    portlet_model { "monitor" }
  end

  trait :gws_portal_preset_board_portlet do
    portlet_model { "board" }
  end

  trait :gws_portal_preset_faq_portlet do
    portlet_model { "faq" }
  end

  trait :gws_portal_preset_qna_portlet do
    portlet_model { "qna" }
  end

  trait :gws_portal_preset_share_portlet do
    portlet_model { "share" }
  end

  trait :gws_portal_preset_attendance_portlet do
    portlet_model { "attendance" }
  end

  trait :gws_portal_preset_notice_portlet do
    portlet_model { "notice" }
  end

  trait :gws_portal_preset_presence_portlet do
    portlet_model { "presence" }
  end

  trait :gws_portal_preset_survey_portlet do
    portlet_model { "survey" }
  end

  trait :gws_portal_preset_ad_portlet do
    portlet_model { "ad" }
  end
=end
end
