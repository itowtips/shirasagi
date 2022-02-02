require 'spec_helper'

describe Gws::Schedule::PlanHelper, type: :helper, dbscope: :example do
  before do
    helper.instance_variable_set :@cur_user, gws_user
    helper.instance_variable_set :@cur_site, gws_site
  end

  describe "#term" do
    context "usual case" do
      let(:item) { create :gws_schedule_plan }

      it "same allday" do
        item.allday   = 'allday'
        item.start_on = '2016-01-01'
        item.end_on   = '2016-01-01'
        term = helper.term(item)
        expect(term).to eq I18n.l(item.start_on, format: :gws_long)
      end

      it "different allday" do
        item.allday   = 'allday'
        item.start_on = '2016-01-01'
        item.end_on   = '2016-01-02'
        term = helper.term(item)

        start_at = I18n.l(item.start_on, format: :gws_long)
        end_at = I18n.l(item.end_on, format: :gws_long_without_year)
        expect(term).to eq "#{start_at} - #{end_at}"
      end

      it "same timestamp" do
        item.start_at = '2016-01-01 00:00:00'
        item.end_at   = '2016-01-01 00:00:00'
        term = helper.term(item)
        expect(term).to eq I18n.l(item.start_at, format: :gws_long)
      end

      it "different hour" do
        item.start_at = '2016-01-01 00:00:00'
        item.end_at   = '2016-01-01 01:00:00'
        term = helper.term(item)

        start_at = I18n.l(item.start_at, format: :gws_long)
        end_at = I18n.l(item.end_at, format: :gws_long_without_year_month_day)
        expect(term).to eq "#{start_at} - #{end_at}"
      end

      it "different day" do
        item.start_at = '2016-01-01 00:00:00'
        item.end_at   = '2016-01-02 00:00:00'
        term = helper.term(item)

        start_at = I18n.l(item.start_at, format: :gws_long)
        end_at = I18n.l(item.end_at, format: :gws_long_without_year)
        expect(term).to eq "#{start_at} - #{end_at}"
      end

      it "different month" do
        item.start_at = '2016-01-01 00:00:00'
        item.end_at   = '2016-02-01 00:00:00'
        term = helper.term(item)

        start_at = I18n.l(item.start_at, format: :gws_long)
        end_at = I18n.l(item.end_at, format: :gws_long_without_year)
        expect(term).to eq "#{start_at} - #{end_at}"
      end

      it "different year" do
        item.start_at = '2016-01-01 00:00:00'
        item.end_at   = '2017-01-01 00:00:00'
        term = helper.term(item)

        start_at = I18n.l(item.start_at, format: :gws_long)
        end_at = I18n.l(item.end_at, format: :gws_long)
        expect(term).to eq "#{start_at} - #{end_at}"
      end
    end

    context "all day event to show in different timezone" do
      let(:zone) { "Eastern Time (US & Canada)" }
      let(:start_on) { '2016-01-01' }
      let(:end_on) { '2016-01-02' }
      let(:item) do
        Time.use_zone(zone) do
          create(:gws_schedule_plan, allday: 'allday', start_on: start_on, end_on: end_on)
        end
      end

      it do
        term = helper.term(item)

        start_at = I18n.l(item.start_on, format: :gws_long)
        end_at = I18n.l(item.end_on, format: :gws_long_without_year)
        expect(term).to eq "#{start_at} - #{end_at}"
      end
    end
  end

  describe "calendar_format" do
    let!(:user) { gws_user }
    let!(:item) { create :gws_schedule_plan }

    it "events" do
      opts = {}
      opts[:user] = user.id
      opts[:cur_user] = user
      plans  = Gws::Schedule::Plan.all
      events = helper.calendar_format(plans, opts)
      expect(events.present?).to eq true
    end
  end

  describe "group_holidays" do
    let!(:item) { create :gws_schedule_holiday, start_on: '2016-01-01', end_on: '2016-01-01' }

    it "events" do
      start_at = Date.parse('2016-01-01')
      end_at   = Date.parse('2016-02-01')
      events   = helper.group_holidays(start_at, end_at)
      expect(events.size).to eq 1
    end
  end

  describe "calendar_holidays" do
    it "events" do
      start_at = Date.parse('2016-01-01')
      end_at   = Date.parse('2016-02-01')
      events   = helper.calendar_holidays(start_at, end_at)
      expect(events.size).to eq 2
    end
  end
end
