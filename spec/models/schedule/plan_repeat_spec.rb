require 'spec_helper'

RSpec.describe Schedule::PlanRepeat, type: :model, dbscope: :example do
  describe 'entry schedule' do
    it 'create daily plan' do
      create :schedule_repeat, :daily

      expect(Schedule::Plan.count).to eq 5
    end

    it 'create weekly plan' do
      create :schedule_repeat, :weekly

      expect(Schedule::Plan.count).to eq 5
    end

    describe 'create monthly plan' do
      it 'by date' do
        create :schedule_repeat, :monthly_by_date

        expect(Schedule::Plan.count).to eq 6
      end

      it 'by week' do
        create :schedule_repeat, :monthly_by_week

        expect(Schedule::Plan.count).to eq 6
      end
    end
  end

  describe 'delete schedule' do
    subject(:schedule_repeat) { create :schedule_repeat, :daily }

    it 'delete all schedule' do
      schedule_repeat.destroy
      expect(Schedule::Plan.count).to eq 0
    end

    it 'delete schedule for april 3 and later' do
      schedule_repeat.delete_schedule_plan(Time.zone.local(2015, 4, 3))
      expect(Schedule::Plan.count).to eq 2
      expect(Schedule::Plan.order_by(:start_at.desc).first.start_at).to be < Time.zone.local(2015, 4, 3)
    end
  end

  describe 'get_date_next_specified_wday method' do
    subject(:sunday) { Time.zone.local(2015, 4, 5) }
    subject(:schedule_repeat) { build :schedule_repeat }

    it 'get sunday' do
      expect(schedule_repeat.get_date_next_specified_wday(sunday, 0)).to eq sunday
    end

    it 'get monday' do
      expect(schedule_repeat.get_date_next_specified_wday(sunday, 1)).to eq sunday + 1.day
    end

    it 'get tuesday' do
      expect(schedule_repeat.get_date_next_specified_wday(sunday, 2)).to eq sunday + 2.day
    end

    it 'get wednesday' do
      expect(schedule_repeat.get_date_next_specified_wday(sunday, 3)).to eq sunday + 3.day
    end

    it 'get thursday' do
      expect(schedule_repeat.get_date_next_specified_wday(sunday, 4)).to eq sunday + 4.day
    end

    it 'get friday' do
      expect(schedule_repeat.get_date_next_specified_wday(sunday, 5)).to eq sunday + 5.day
    end

    it 'get saturday' do
      expect(schedule_repeat.get_date_next_specified_wday(sunday, 6)).to eq sunday + 6.day
    end
  end

  describe 'get_entry_dates_weekly method' do
    subject(:schedule_weekly) { build :schedule_repeat, :weekly }

    it 'return array of five elements' do
      expect(schedule_weekly.get_entry_dates_weekly.size).to eq 5
    end

    it 'include april 29' do
      expect(schedule_weekly.get_entry_dates_weekly).to include Time.zone.local(2015, 4, 29)
    end

    describe 'add conditions' do
      subject(:mon_fri) { Schedule::PlanRepeatOn.new(monday: true, friday: true) }

      before do
        schedule_weekly.repeat_on = mon_fri
      end

      it 'return array of ten elements' do
        expect(schedule_weekly.get_entry_dates_weekly.size).to eq 8
      end

      it 'include april 27' do
        expect(schedule_weekly.get_entry_dates_weekly).to include Time.zone.local(2015, 4, 27)
      end
    end
  end

  describe 'get_entry_dates_monthly_by_date method' do
    subject(:schedule_monthly) { build :schedule_repeat, :monthly_by_date }

    it 'return array of six elements' do
      expect(schedule_monthly.get_entry_dates_monthly_by_date.size).to eq 6
    end

    it 'include september 1' do
      expect(schedule_monthly.get_entry_dates_monthly_by_date).to include Time.zone.local(2015, 9, 1)
    end
  end

  describe 'get_entry_dates_monthly_by_week method' do
    subject(:schedule_monthly) { build :schedule_repeat, :monthly_by_week }

    it 'return array of six elements' do
      expect(schedule_monthly.get_entry_dates_monthly_by_week.size).to eq 6
    end

    it 'include september 2' do
      expect(schedule_monthly.get_entry_dates_monthly_by_week).to include Time.zone.local(2015, 9, 2)
    end
  end

  describe 'get_week_number_of_month method' do
    subject(:schedule_repeat) { build :schedule_repeat }

    it 'return 1 specify 2015/04/01' do
      expect(schedule_repeat.get_week_number_of_month(Time.zone.local(2015, 4, 1))).to eq 1
    end

    it 'return 1 specify 2015/04/05' do
      expect(schedule_repeat.get_week_number_of_month(Time.zone.local(2015, 4, 5))).to eq 1
    end

    it 'return 4 specify 2015/04/26' do
      expect(schedule_repeat.get_week_number_of_month(Time.zone.local(2015, 4, 26))).to eq 4
    end

    it 'return 5 specify 2015/04/30' do
      expect(schedule_repeat.get_week_number_of_month(Time.zone.local(2015, 4, 30))).to eq 5
    end
  end

  describe 'get_date_by_ordinal_week method' do
    subject(:schedule_repeat) { build :schedule_repeat, :monthly_by_week }

    it 'return 2015/04/01' do
      expect(schedule_repeat.get_date_by_ordinal_week(2015, 4, 1, 3)).to eq Time.zone.local(2015, 4, 1)
    end

    it 'return 2015/05/27' do
      expect(schedule_repeat.get_date_by_ordinal_week(2015, 5, 4, 3)).to eq Time.zone.local(2015, 5, 27)
    end
  end

  describe 'entry_schedule_plan method' do
    subject(:schedule_repeat) { build :schedule_repeat }

    before do
      schedule_repeat.entry_schedule_plan([Time.zone.local(2015, 4, 1)])
    end

    it "create one Schedule::Plan data" do
      expect(Schedule::Plan.count).to eq 1
    end

    it "create data check" do
      schedule_plan = Schedule::Plan.all.first
      expect(schedule_plan.name).to eq schedule_repeat.name
      expect(schedule_plan.text).to eq schedule_repeat.text
      expect(schedule_plan.start_at).to eq schedule_repeat.start_at
      expect(schedule_plan.end_at).to eq schedule_repeat.end_at
      expect(schedule_plan.allday).to eq schedule_repeat.allday
    end
  end
end
