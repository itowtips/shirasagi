class Cms::Line::MessagesController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Cms::Line::Message

  navi_view "cms/line/main/navi"

  private

  def set_crumbs
    @crumbs << [t("cms.line_message"), cms_line_messages_path]
  end

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site }
  end

  def set_items
    super
    @items = @items.order_by(updated: -1)
  end

  public

  def deliver
    set_item
    return if request.get?

    if @item.deliver
      redirect_to({ action: :show }, { notice: I18n.t("ss.notice.started_deliver") })
    end
  end

  def test_deliver
    set_item
    return if request.get?

    @test_member_ids = params.dig(:item, :test_member_ids).to_a.map(&:to_i)
    @test_members = Cms::Line::TestMember.site(@cur_site).in(id: @test_member_ids).to_a

    if @test_members.blank?
      @item.errors.add :base, "テストメンバーが選択されていません。"
      return
    end

    if @item.test_deliver(@test_members)
      redirect_to({ action: :show}, { notice: I18n.t("ss.notice.started_test_deliver") })
    end
  end
end
