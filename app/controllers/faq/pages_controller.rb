require "open3"
require "csv"

class Faq::PagesController < ApplicationController
  include Cms::BaseFilter
  include Cms::PageFilter
  include Workflow::PageFilter

  model Faq::Page

  append_view_path "app/views/cms/pages"
  menu_view "faq/pages/menu"
  navi_view "faq/main/navi"

  private
    def send_csv(items)
      require "csv"

      csv = CSV.generate do |data|
        data << %w(
          FAQコード（ファイル名）
          大カテゴリ
          小カテゴリ
          ライフイベント（未使用）
          サブライフイベント（未使用）
          質問
          回答
          内部参考情報（未使用）
          担当部局
          担当課
          参考URL（未使用）
          関連資料（未使用）
          公開区分（未使用）
          公開日
          公開期限
          )

        items.each do |item|
          question   = item.question.present? ? item.question : item.name
          categories = item.categories.entries
          group      = item.contact_group
          ka         = group.name.scan(/[^\/]+?課/).shift if group
          bu         = group.name.scan(/[^\/]+?部/).shift if group

          release_date = item.release_date
          close_date   = item.close_date
          release_date = release_date.strftime("%Y/%m/%d %X") if release_date
          close_date   = close_date.strftime("%Y/%m/%d %X") if close_date

          row = []
          row << item.basename.sub(/\.html$/, "")  # 〇 page basename (faq code)
          row << categories.shift.try(:name)       # 〇 large faq category
          row << categories.shift.try(:name)       # 〇 small faq category
          row << ""                                # × life event1
          row << ""                                # × life event2
          row << question                          # 〇 question
          row << item.html                         # 〇 answer
          row << ""                                # × info
          row << bu                                # 〇 large group
          row << ka                                # 〇 small group
          row << ""                                # × related url
          row << ""                                # × related docs
          row << ""                                # × division
          row << release_date                      # 〇 release_date
          row << close_date                        # 〇 close_date
          data << row
        end
      end

      send_data csv.encode("SJIS", invalid: :replace, undef: :replace), filename: "faq_pages_#{Time.now.to_i}.csv"
    end

    def fix_params
      { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node }
    end

  public
    def download
      @items = Faq::Page.
        where(site_id: @cur_site.id, filename: /^#{@cur_node.filename}\//, depth: @cur_node.depth + 1)
      send_csv @items
    end

    def import
      return if request.get?
      @item = Faq::Page.new

      if params[:item] && params[:item][:file]
        begin
          if ::File.extname(params[:item][:file].original_filename) != ".csv"
            raise "CSV形式のファイルを選択してください。"
          end

          # copy to cur_node faq_csv
          csv_path = "#{SS::File.root}/#{@cur_node.filename}/#{Time.now.to_i}.csv"
          Fs.binwrite csv_path, params[:item][:file].read

          # dummy read
          table = CSV.read(csv_path, headers: true, encoding: 'SJIS:UTF-8')
          table.each_with_index do |row, idx|
            #
          end

          # delete all documents
          Faq::Page.where(site_id: @cur_site.id, filename: /^#{@cur_node.filename}\//, depth: @cur_node.depth + 1).destroy_all

          # call job
          @job = Faq::Page::ImportJob.call_async(csv_path, @cur_node.filename, @cur_site.host) do |job|
            job.site_id = @cur_site.id
          end
          cmd = "bundle exec rake job:run RAILS_ENV=#{Rails.env}"
          logger.debug("system: #{cmd}")
          pid = spawn(cmd, close_others: true)
          #Process.detach(pid)

          flash.now[:notice] = "FAQ記事の更新処理を開始しました。"
        rescue => e
          @item.errors.add :base, "エラーが発生しました。: #{e.to_s}"
        end
      end
    end
end
