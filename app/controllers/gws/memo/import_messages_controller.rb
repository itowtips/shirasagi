class Gws::Memo::ImportMessagesController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter

  model Gws::Memo::Message

  navi_view "gws/memo/management/navi"
  menu_view nil

  before_action :deny_with_auth

  private

  def deny_with_auth
    raise "403" unless @model.allowed?(:edit, @cur_user, site: @cur_site)
  end

  def set_crumbs
    @crumbs << [@cur_site.menu_memo_label || t('mongoid.models.gws/memo/message'), gws_memo_messages_path ]
    @crumbs << [t('ss.management'), gws_memo_management_main_path ]
    @crumbs << [t('gws/memo/message.import_messages'), gws_memo_import_messages_path ]
  end

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site }
  end

  public

  def index
    @model.new
  end

  def import
    @item = Gws::Memo::MessageImporter.new get_params
    @item.import_messages
  end
end
