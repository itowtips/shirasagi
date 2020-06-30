class Garbage::NodesController < ApplicationController
  include Cms::BaseFilter
  include Cms::NodeFilter

  model Garbage::Node::Page

  private

  def redirect_url
    diff = (@item.route.pluralize != "garbage/pages")
    diff ? node_node_path(cid: @cur_node, id: @item.id) : { action: :show, id: @item.id }
  end

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node }
  end

  def set_task
    @task = Cms::Task.find_or_create_by name: task_name, site_id: @cur_site.id, node_id: @cur_node.id
  end

  def task_name
    "garbage:import_node_pages"
  end

  def send_csv(items)
    require "csv"

    csv = CSV.generate do |data|
      data << [
        @model.t(:category_ids),
        @model.t(:name),
        @model.t(:remark),
        @model.t(:kana),
        @model.t(:filename),
        @model.t(:layout),
        @model.t(:groups),
        @model.t(:order)
      ]
      items.each do |item|
        item.categories.pluck(:name).each do |category|
          row = []
          row << category
          row << item.name
          row << item.remark
          row << item.kana
          row << item.basename
          row << item.layout.try(:name)
          row << item.groups.pluck(:name).join("_n")
          row << item.order
          data << row
        end
      end
    end

    csv = "\uFEFF" + csv

    send_data csv.encode("UTF-8", invalid: :replace, undef: :replace),
      filename: "target.csv"
  end

  public

  def download
    send_csv @cur_node.children.sort(order: "ASC").map(&:becomes_with_route)
  end

  def import
    raise "403" unless @model.allowed?(:import, @cur_user, site: @cur_site, node: @cur_node, owned: true)

    set_task

    if request.get?
      respond_to do |format|
        format.html { render }
        format.json { render json: @task.to_json(methods: :head_logs) }
      end
      return
    end

    @item = @model.new

    begin
      file = params[:item].try(:[], :file)
      if file.nil? || ::File.extname(file.original_filename) != ".csv"
        raise I18n.t("facility.import.invalid_file")
      end
      if !Garbage::Node::Importer.valid_csv?(file)
        raise I18n.t("errors.messages.malformed_csv")
      end

      # save csv to use in job
      ss_file = SS::File.new
      ss_file.in_file = file
      ss_file.model = "garbage/file"
      ss_file.save

      # call job
      Garbage::ImportJob.bind(site_id: @cur_site, node_id: @cur_node, user_id: @cur_user).perform_later(ss_file.id)
    rescue => e
      @item.errors.add :base, e.to_s
    end

    if @item.errors.present?
      render
    else
      redirect_to({ action: :import }, { notice: I18n.t("ss.notice.started_import") })
    end
  end
end
