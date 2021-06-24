class Guide::Importer
  include ActiveModel::Model
  include SS::PermitParams
  include Cms::SitePermission
  include Cms::CsvImportBase

  set_permission_name "guide_procedures"

  attr_accessor :cur_site, :cur_node, :cur_user
  attr_accessor :in_file

  permit_params :in_file

  def import_procedures
    return false unless validate_import

    @row_index = 0
    self.class.each_csv(in_file) do |row|
      @row_index += 1
      @row = row
      save_procedure
    end

    errors.empty?
  end

  def save_procedure
    id = @row["id"]
    if id.present?
      item = Guide::Procedure.site(cur_site).node(cur_node).where(id: id).first
      if item.nil?
        errors.add :base, "#{id} 見つかりませんでした。"
        return false
      end
    else
      item = Guide::Procedure.new(cur_site: cur_site, cur_node: cur_node, cur_user: cur_user)
    end
    headers = %w(name link_url order procedure_location belongings procedure_applicant remarks)
    headers.each do |k|
      item.send("#{k}=", @row[Guide::Procedure.t(k)])
    end

    if item.save
      true
    else
      errors.add :base, "保存に失敗しました。"
      false
    end
  end

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
          labels = []
          labels << edge.export_label
          edge.points.each do |point|
            labels << point.export_label
          end
          row << labels.join("\n")
        end
        y << encode_sjis(row.to_csv)
      end
    end
  end

  private

  def validate_import
    if in_file.blank?
      errors.add(:base, I18n.t('ss.errors.import.blank_file'))
      return
    end

    if ::File.extname(in_file.original_filename).casecmp(".csv") != 0
      errors.add(:base, I18n.t('ss.errors.import.invalid_file_type'))
      return
    end

    unless self.class.valid_csv?(in_file, max_read_lines: 1)
      errors.add(:base, I18n.t('ss.errors.import.invalid_file_type'))
      return
    end

    true
  end

  def encode_sjis(str)
    str.encode("SJIS", invalid: :replace, undef: :replace)
  end
end
