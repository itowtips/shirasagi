class Guide::Importer
  include ActiveModel::Model
  include Cms::SitePermission

  set_permission_name "guide_procedures"

  attr_accessor :cur_site, :cur_node, :cur_user

  def procedures_enum
    Enumerator.new do |y|
      headers = %w(id name link_url order procedure_location belongings procedure_applicant remarks).map { |v| Guide::Procedure.t(v) }
      y << encode_sjis(headers.to_csv)
      Guide::Procedure.site(cur_site).node(cur_node).each do |item|
        row = []
        row << item.id
        row << item.name
        row << item.link_url
        row << item.order
        row << item.procedure_location
        row << item.belongings
        row << item.procedure_applicant
        row << item.remarks
        y << encode_sjis(row.to_csv)
      end
    end
  end

  def questions_enum
    Enumerator.new do |y|
      headers = %w(id name question_type check_type).map { |v| Guide::Question.t(v) }
      edge_size = Guide::Question.site(cur_site).node(cur_node).map { |item| item.edges.size }.max
      edge_size.times do |i|
        headers << "選択肢#{i + 1}"
      end
      y << encode_sjis(headers.to_csv)
      Guide::Question.site(cur_site).node(cur_node).each do |item|
        row = []
        row << item.id
        row << item.name
        row << item.label(:question_type)
        row << item.label(:check_type)
        item.edges.each do |edge|
          row << edge.value
        end
        y << encode_sjis(row.to_csv)
      end
    end
  end

  def transitions_enum
    Enumerator.new do |y|
      headers = %w(id name).map { |v| Guide::Question.t(v) }
      edge_size = Guide::Question.site(cur_site).node(cur_node).map { |item| item.edges.size }.max
      edge_size.times do |i|
        headers << "選択肢#{i + 1}"
      end
      y << encode_sjis(headers.to_csv)
      Guide::Question.site(cur_site).node(cur_node).each do |item|
        row = []
        row << item.id
        row << item.name
        item.edges.map do |edge|
          row << ([edge.label] + edge.points.map(&:label)).join("\n")
        end
        y << encode_sjis(row.to_csv)
      end
    end
  end

  private

  def encode_sjis(str)
    str.encode("SJIS", invalid: :replace, undef: :replace)
  end
end
