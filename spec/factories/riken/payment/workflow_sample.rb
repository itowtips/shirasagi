FactoryBot.define do
  factory :riken_payment_workflow_sample, class: Riken::Payment::WorkflowSample do
    cur_site { gws_site }
    name { unique_id }

    # api attributes
    workflow_id { "123456" }
    status { "0" }
    url { "https://proxyapp.intra.riken.jp/" }
    update_time { "99991231235959" }
    delegation_start_date { "20220401" }
    delegation_end_date { "20230331" }
    proxy_id { "123456" }
    proxy_name { "理研 課員" }
    proxy_lab { "本部総務部総務課" }
    proxy_position { "課・室員" }
    authorizer_id { "789012" }
    authorizer_name { "理研 課長" }
    authorizer_lab { "本部総務部総務課" }
    authorizer_position { "課長" }
    delegation_1 { "1" }
    delegation_2 { "1" }
    delegation_3 { "1" }
    note { "メモ" }
    create_time { "99991231235959" }
    create_id { "123456" }
    create_name { "理研 課員" }
    create_lab { "本部総務部総務課" }
    create_position { "課・室員" }
  end
end
