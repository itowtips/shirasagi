class JobDb::PortalController < ApplicationController
  include JobDb::BaseFilter
  helper JobDb::BaseHelper

  private
    def set_crumbs
      @crumbs << [:"job_db.portal", job_db_portal_path]
    end

  public
    def index
      items_limit = SS.config.job_db.portal['items_limit']

      @sys_notices = Sys::Notice.and_public.sys_admin_notice.page(1).per(items_limit)

      @cur_cms_user = Cms::User.find(@cur_user.id)
      @cms_contents = Cms::Node.where(shortcut: :show).order_by(filename: 1)
      @cms_contents = @cms_contents.all.select do |item|
        item.cur_site = item.site
          item.allowed?(:read, @cur_cms_user)
      end
    end
end
