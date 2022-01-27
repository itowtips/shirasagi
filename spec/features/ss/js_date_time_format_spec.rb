require 'spec_helper'

describe "js_date_time_format", type: :feature, dbscope: :example, js: true do
  let(:script) do
    <<~SCRIPT.freeze
      moment(arguments[0]).format(SS.convertDateTimeFormat(arguments[1]))
    SCRIPT
  end
  let(:now) { Time.zone.now.change(usec: 0) }

  it do
    visit sns_login_path

    '%Y-%1m-%1d (%a)'.tap do |format|
      val = page.evaluate_script(script, now.iso8601, format)
      # I18n.l localize '%a' but strftime doesn't
      expect(val).to eq I18n.l(now, format: format)
      expect(val).not_to eq now.strftime(format)
    end
    '%m月%d日 (%a)'.tap do |format|
      val = page.evaluate_script(script, now.iso8601, format)
      # I18n.l localize '%a' but strftime doesn't
      expect(val).to eq I18n.l(now, format: format)
      expect(val).not_to eq now.strftime(format)
    end
    '%Y/%1m/%1d %H:%M'.tap do |format|
      val = page.evaluate_script(script, now.iso8601, format)
      expect(val).to eq I18n.l(now, format: format)
      expect(val).to eq now.strftime(format)
    end
    '%Y-%m-%d %H:%M'.tap do |format|
      val = page.evaluate_script(script, now.iso8601, format)
      expect(val).to eq I18n.l(now, format: format)
      expect(val).to eq now.strftime(format)
    end
    '%Y年%1m月%1d日 %H時%M分'.tap do |format|
      val = page.evaluate_script(script, now.iso8601, format)
      expect(val).to eq I18n.l(now, format: format)
      expect(val).to eq now.strftime(format)
    end
    '%y/%m/%d %H:%M'.tap do |format|
      val = page.evaluate_script(script, now.iso8601, format)
      expect(val).to eq I18n.l(now, format: format)
      expect(val).to eq now.strftime(format)
    end
    '%Y/%m/%d %H:%M'.tap do |format|
      val = page.evaluate_script(script, now.iso8601, format)
      expect(val).to eq I18n.l(now, format: format)
      expect(val).to eq now.strftime(format)
    end
  end
end
