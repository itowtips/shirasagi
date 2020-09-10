def create_affair_user1(date)
  create_gws_users

  site = Gws::Group.find_by(name: "シラサギ市")
  group = Gws::Group.find_by(name: "シラサギ市/企画政策部/政策課")
  role = Gws::Role.site(site).find_by(name: I18n.t('gws.roles.admin'))

  user = Gws::User.create name: "affair1", uid: "affair1", email: "affair1@example.jp", in_password: "pass",
    group_ids: [group.id], gws_role_ids: [role.id], organization_id: site.id

  affair_punch_time_card(site, user, date)
  user
end

def create_affair_user2(date)
  create_gws_users

  site = Gws::Group.find_by(name: "シラサギ市")
  group = Gws::Group.find_by(name: "シラサギ市/企画政策部/政策課")
  role = Gws::Role.site(site).find_by(name: I18n.t('gws.roles.admin'))

  user = Gws::User.create name: "affair2", uid: "affair2", email: "affair2@example.jp", in_password: "pass",
    group_ids: [group.id], gws_role_ids: [role.id], organization_id: site.id

  # 8:30 - 17:00 (7.75) 休憩45
  duty_hour = create(:gws_affair_duty_hour)
  duty_calendar = create(:gws_affair_duty_calendar, duty_hour_ids: [duty_hour.id], member_ids: [user.id])

  affair_punch_time_card(site, user, date)

  user
end

def create_affair_user3(date)
  create_gws_users

  site = Gws::Group.find_by(name: "シラサギ市")
  group = Gws::Group.find_by(name: "シラサギ市/企画政策部/政策課")
  role = Gws::Role.site(site).find_by(name: I18n.t('gws.roles.admin'))

  user = Gws::User.create name: "affair3", uid: "affair3", email: "affair3@example.jp", in_password: "pass",
     group_ids: [group.id], gws_role_ids: [role.id], organization_id: site.id

  # 8:00 - 12:00 (4.0) 休憩0 時短
  duty_hour = create(:gws_affair_duty_hour_short)
  duty_calendar = create(:gws_affair_duty_calendar, duty_hour_ids: [duty_hour.id], member_ids: [user.id])

  affair_punch_time_card(site, user, date)

  user
end

def affair_punch_time_card(site, user, date)
  def punch(site, date, user, action, box = "today-box")
    Timecop.freeze(date) do
      login_user(user)
      visit gws_affair_attendance_time_card_main_path(site)
      within ".#{box} .today .action .#{action}" do
        page.accept_confirm do
          click_on I18n.t('gws/attendance.buttons.punch')
        end
      end
      expect(page).to have_css('#notice', text: I18n.t('gws/attendance.notice.punched'))
    end
  end

  day1 = date
  day2 = day1.advance(days: 1)
  day3 = day1.advance(days: 2)
  day4 = day1.advance(days: 3)

  day1_0800 = day1.change(hour: 8, min: 0, sec: 0)
  day1_1800 = day1.change(hour: 18, min: 0, sec: 0)

  day2_0830 = day2.change(hour: 8, min: 30, sec: 0)
  day2_2000 = day2.change(hour: 20, min: 0, sec: 0)

  day3_0900 = day3.change(hour: 9, min: 0, sec: 0)
  day3_2310 = day3.change(hour: 23, min: 10, sec: 0)

  day4_0700 = day4.change(hour: 7, min: 0, sec: 0)
  day4_2800 = day4.advance(days: 1).change(hour: 4, min: 0, sec: 0)

  punch(site, day1_0800, user, "enter")
  punch(site, day1_1800, user, "leave")

  punch(site, day2_0830, user, "enter")
  punch(site, day2_2000, user, "leave")

  punch(site, day3_0900, user, "enter")
  punch(site, day3_2310, user, "leave")

  punch(site, day4_0700, user, "enter")
  punch(site, day4_2800, user, "leave", "yesterday-box")
end

def affair_punch_enter
  within '.today-box .today .action .enter' do
    page.accept_confirm do
      click_on I18n.t('gws/attendance.buttons.punch')
    end
  end
end

def affair_punch_leave
  within '.today-box .today .action .leave' do
    page.accept_confirm do
      click_on I18n.t('gws/attendance.buttons.punch')
    end
  end
end
