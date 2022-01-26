class SS::Migration20220125000001
  include SS::Migration::Base

  depends_on "20211110000000"

  def change
    each_item do |item|
      item.send(:synchronize_i18n_name)
      item.save
    end
  end

  private

  def each_item(&block)
    cirteria = SS::Group.all.unscoped.exists(i18n_name: false)
    all_ids = cirteria.pluck(:id)
    all_ids.each_slice(20) do |ids|
      cirteria.in(id: ids).to_a.each(&block)
    end
  end
end
