module Gws::Discussion
  class Initializer
    Gws::Role.permission :read_other_gws_discussion_topics, module_name: 'gws/discussion'
    Gws::Role.permission :read_private_gws_discussion_topics, module_name: 'gws/discussion'
    Gws::Role.permission :edit_other_gws_discussion_topics, module_name: 'gws/discussion'
    Gws::Role.permission :edit_private_gws_discussion_topics, module_name: 'gws/discussion'
    Gws::Role.permission :delete_other_gws_discussion_topics, module_name: 'gws/discussion'
    Gws::Role.permission :delete_private_gws_discussion_topics, module_name: 'gws/discussion'
  end
end
