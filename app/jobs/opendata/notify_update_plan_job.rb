class Opendata::NotifyUpdatePlanJob < Cms::ApplicationJob
  def put_log(message)
    Rails.logger.warn(message)
    puts message
  end

  def perform
    datasets = []

    dataset_ids = Opendata::Dataset.site(site).where(
      :update_plan_date.exists => true,
      :update_plan_date_mail_state => "enabled"
    ).pluck(:id)
    dataset_ids.each do |id|
      dataset = Opendata::Dataset.find(id) rescue nil
      next unless dataset
      datasets << dataset if dataset.update_plan_date.today?
    end

    if datasets.present?
      Opendata::Mailer.notify_dataset_update_plan(site, datasets).deliver_now
      datasets.each { |dataset| dataset.set(update_plan_date_mail_state: "disabled") }
    end

    put_log("send notify mails #{datasets.size}")
  end
end
