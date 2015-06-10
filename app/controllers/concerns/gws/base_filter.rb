module Gws::BaseFilter
  extend ActiveSupport::Concern
  include SS::BaseFilter

  included do
    before_action :set_assets
    before_action :set_cur_org
    before_action :set_group

    def current_group
      @cur_group
    end

    def current_organization
      @cur_org
    end

    private
      def set_assets
        javascript 'gws/script'
        stylesheet 'gws/style'
      end

      # Set the instance variable of `@cur_org`.
      # When a request path is `/..g123/schedule/plan/new`, `group` becomes
      # `123` and set `SS::Group` instance whose ID is 123 to `@cur_org`.
      def set_cur_org
        @cur_org = SS::Group.find params[:group]
        raise "404" unless @cur_org
      end

      # Set current user's group by `@cur_org`.
      def set_group
        cur_groups = @cur_user.groups.in(name: /^#{@cur_org.name}(\/|$)/)
        @cur_group = cur_groups.first # select one group
        raise "403" unless @cur_group
      end
  end
end
