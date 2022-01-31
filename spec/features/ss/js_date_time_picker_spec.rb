require 'spec_helper'

describe "SS_DateTimePicker", type: :feature, dbscope: :example, js: true do
  let(:create_input_script) do
    <<~SCRIPT.freeze
      (function(formData, id, type, resolve) {
        SS_DateTimePicker.hasFormDataEvent = function() { return !!formData; };

        var $dateTime = $("<input />", { type: "text", id: id, name: id });
        $("form").attr("action", "#{sys_diag_server_path}").append($dateTime);

        var picker = new SS_DateTimePicker($dateTime, type);
        picker.once("generate", function() {
          resolve(true);
        });
        picker.on("changeDateTime", function() {
          $dateTime.trigger("ss:changeDateTime")
        });

      })(...arguments);
    SCRIPT
  end
  let(:id) { "date-#{unique_id}" }
  let(:now) { Time.zone.now.change(min: 30, sec: 0, usec: 0) }

  shared_examples "SS_DateTimePicker is" do
    around do |example|
      I18n.with_locale(lang.to_sym) { example.run }
    end

    before do
      sys_user.update(lang: lang.to_s)

      login_sys_user
    end

    context "with datetime" do
      it do
        visit edit_sns_cur_user_account_path

        # create datetimepicker with empty value
        expect(page.evaluate_async_script(create_input_script, form_data, id, "datetime")).to be_truthy

        # just after initialized
        expect(page.evaluate_script("SS_DateTimePicker.momentValue('##{id}')")).to be_blank
        expect(page.evaluate_script("$('##{id}').val()")).to be_blank
        # datetimepicker のバグだと思うが、初期化時に value が nil や空文字の場合、getValue がカレント時刻になってしまう。
        expect(page.evaluate_script("$('##{id}').datetimepicker('getValue')")).to be_present
        unless form_data
          expect(page.evaluate_script("$('[name=\"#{id}\"]').val()")).to be_blank
        end

        # set value
        page.execute_script("SS_DateTimePicker.momentValue('##{id}', moment('#{now.iso8601}'))")

        # get value with different methods
        expect(page.evaluate_script("$('##{id}').val()")).to eq I18n.l(now, format: :picker)
        page.evaluate_script("SS.formatTime($('##{id}').datetimepicker('getValue'), 'picker')").tap do |value|
          expect(value).to eq I18n.l(now, format: :picker)
        end
        page.evaluate_script("SS.formatTime(SS_DateTimePicker.momentValue('##{id}'), 'picker')").tap do |value|
          expect(value).to eq I18n.l(now, format: :picker)
        end
        unless form_data
          page.evaluate_script("SS.formatTime($('[name=\"#{id}\"]').val(), 'picker')").tap do |value|
            expect(value).to eq I18n.l(now, format: :picker)
          end
        end

        # clear value with null
        page.execute_script("SS_DateTimePicker.momentValue('##{id}', null)")

        # get value with different methods
        expect(page.evaluate_script("SS_DateTimePicker.momentValue('##{id}')")).to be_blank
        expect(page.evaluate_script("$('##{id}').val()")).to be_blank
        # datetimepicker のバグだと思うが、表示状は空文字であっても、内部値（getValue）がカレント時刻でないとうまく動作しない場合がある。
        expect(page.evaluate_script("$('##{id}').datetimepicker('getValue')")).to be_present
        unless form_data
          expect(page.evaluate_script("$('[name=\"#{id}\"]').val()")).to be_blank
        end

        wait_event_to_fire("ss:changeDateTime") do
          first("##{id}").click

          expect(page.evaluate_script("$('.xdsoft_datetimepicker').length")).to eq 1

          css_selector = ".xdsoft_date[data-date='11'][data-month='#{now.month - 1}']"
          expect(page.evaluate_script("$(\"#{css_selector}\").length")).to eq 1
          page.execute_script("$(\"#{css_selector}\").trigger('click')")
        end

        expect(page.evaluate_script("$('##{id}').val()")).to eq I18n.l(now.change(day: 11), format: :picker)
        page.evaluate_script("SS.formatTime($('##{id}').datetimepicker('getValue'), 'picker')").tap do |value|
          expect(value).to eq I18n.l(now.change(day: 11), format: :picker)
        end
        page.evaluate_script("SS.formatTime(SS_DateTimePicker.momentValue('##{id}'), 'picker')").tap do |value|
          expect(value).to eq I18n.l(now.change(day: 11), format: :picker)
        end
        unless form_data
          page.evaluate_script("SS.formatTime($('[name=\"#{id}\"]').val(), 'picker')").tap do |value|
            expect(value).to eq I18n.l(now.change(day: 11), format: :picker)
          end
        end

        # check submitted parameter
        click_on I18n.t("ss.buttons.save")
        within "#request-parameters" do
          expect(page).to have_content(I18n.l(now.change(day: 11), format: "%Y/%m/%d %H:%M:%S"))
        end
      end
    end

    context "with date" do
      it do
        visit edit_sns_cur_user_account_path

        # create datetimepicker
        expect(page.evaluate_async_script(create_input_script, true, id, "date")).to be_truthy

        # just after initialized
        expect(page.evaluate_script("SS_DateTimePicker.momentValue('##{id}')")).to be_blank
        expect(page.evaluate_script("$('##{id}').val()")).to be_blank
        # datetimepicker のバグだと思うが、初期化時に value が nil や空文字の場合、getValue がカレント時刻になってしまう。
        expect(page.evaluate_script("$('##{id}').datetimepicker('getValue')")).to be_present
        unless form_data
          expect(page.evaluate_script("$('[name=\"#{id}\"]').val()")).to be_blank
        end

        # set value
        page.execute_script("SS_DateTimePicker.momentValue('##{id}', moment('#{now.iso8601}'))")

        # get value with different methods
        expect(page.evaluate_script("$('##{id}').val()")).to eq I18n.l(now.to_date, format: :picker)
        page.evaluate_script("SS.formatDate($('##{id}').datetimepicker('getValue'), 'picker')").tap do |value|
          expect(value).to eq I18n.l(now.to_date, format: :picker)
        end
        page.evaluate_script("SS.formatDate(SS_DateTimePicker.momentValue('##{id}'), 'picker')").tap do |value|
          expect(value).to eq I18n.l(now.to_date, format: :picker)
        end
        unless form_data
          page.evaluate_script("SS.formatDate($('[name=\"#{id}\"]').val(), 'picker')").tap do |value|
            expect(value).to eq I18n.l(now.to_date, format: :picker)
          end
        end

        # clear value with null
        page.execute_script("SS_DateTimePicker.momentValue('##{id}', null)")

        # get value with different methods
        expect(page.evaluate_script("SS_DateTimePicker.momentValue('##{id}')")).to be_blank
        expect(page.evaluate_script("$('##{id}').val()")).to be_blank
        # datetimepicker のバグだと思うが、表示状は空文字であっても、内部値（getValue）がカレント時刻でないとうまく動作しない場合がある。
        expect(page.evaluate_script("$('##{id}').datetimepicker('getValue')")).to be_present
        unless form_data
          expect(page.evaluate_script("$('[name=\"#{id}\"]').val()")).to be_blank
        end

        wait_event_to_fire("ss:changeDateTime") do
          first("##{id}").click

          expect(page.evaluate_script("$('.xdsoft_datetimepicker').length")).to eq 1

          css_selector = ".xdsoft_date[data-date='11'][data-month='#{now.month - 1}']"
          expect(page.evaluate_script("$(\"#{css_selector}\").length")).to eq 1
          page.execute_script("$(\"#{css_selector}\").trigger('click')")
        end

        expect(page.evaluate_script("$('##{id}').val()")).to eq I18n.l(now.change(day: 11).to_date, format: :picker)
        page.evaluate_script("SS.formatDate($('##{id}').datetimepicker('getValue'), 'picker')").tap do |value|
          expect(value).to eq I18n.l(now.change(day: 11).to_date, format: :picker)
        end
        page.evaluate_script("SS.formatDate(SS_DateTimePicker.momentValue('##{id}'), 'picker')").tap do |value|
          expect(value).to eq I18n.l(now.change(day: 11).to_date, format: :picker)
        end
        unless form_data
          page.evaluate_script("SS.formatDate($('[name=\"#{id}\"]').val(), 'picker')").tap do |value|
            expect(value).to eq I18n.l(now.change(day: 11).to_date, format: :picker)
          end
        end

        # check submitted parameter
        click_on I18n.t("ss.buttons.save")
        within "#request-parameters" do
          expect(page).to have_content(I18n.l(now.change(day: 11), format: "%Y/%m/%d"))
          expect(page).not_to have_content(I18n.l(now.change(day: 11), format: "%Y/%m/%d %H:%M:%S"))
        end
      end
    end
  end

  context "with ja" do
    let(:lang) { :ja }

    context "with formData" do
      let(:form_data) { true }

      it_behaves_like "SS_DateTimePicker is"
    end

    context "without formData" do
      let(:form_data) { false }

      it_behaves_like "SS_DateTimePicker is"
    end
  end

  context "with en" do
    let(:lang) { :en }

    context "with formData" do
      let(:form_data) { true }

      it_behaves_like "SS_DateTimePicker is"
    end

    context "without formData" do
      let(:form_data) { false }

      it_behaves_like "SS_DateTimePicker is"
    end
  end
end
