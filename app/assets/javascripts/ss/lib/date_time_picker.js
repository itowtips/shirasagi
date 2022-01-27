this.SS_DateTimePicker = (function () {
  function SS_DateTimePicker(el, type) {
    this.$el = $(el);

    if (!type) {
      if (this.$el.hasClass("js-date")) {
        type = "date"
      } else {
        type = "datetime"
      }
    }
    this.type = type;

    this.render();
  }

  var initialized = false;

  SS_DateTimePicker.renderOnce = function() {
    if (initialized) {
      return;
    }

    $.datetimepicker.setLocale(document.documentElement.lang || 'ja');
    // setLocale() を呼び出すと dateFormatter がリセットされるので、setLocale() の後に setDateFormatter() を呼び出さなければならない。
    $.datetimepicker.setDateFormatter('moment');

    initialized = true;
  };

  SS_DateTimePicker.render = function() {
    SS_DateTimePicker.renderOnce();

    $(".js-date,.js-datetime").each(function() {
        var $this = $(this);
        var data = $this.data();
        if ("ss_datetimepicker" in data) {
          // already instantiated
          return;
        }

        var picker = new SS_DateTimePicker(this);
        $this.data("ss_datetimepicker", picker);
    });
  };

  SS_DateTimePicker.prototype.render = function() {
    var options
    if (this.type === "date") {
      options = this.buildDatePickerOptions();
    } else {
      options = this.buildDateTimePickerOptions();
    }

    this.$el.attr('autocomplete', 'off').datetimepicker(options);
  };

  SS_DateTimePicker.prototype.buildDatePickerOptions = function() {
    var opts = {
      timepicker: false,
      format: SS.convertDateTimeFormat(i18next.t("date.formats.picker")),
      closeOnDateSelect: true,
      scrollInput: false
    };

    var data = this.$el.data();
    if (data.format) {
      opts.format = data.format;
    }
    if ("closeOnDateSelect" in data) {
      opts.closeOnDateSelect = data.closeOnDateSelect;
    }
    if ("scrollInput" in data) {
      opts.scrollInput = data.scrollInput;
    }
    if (data.minDate) {
      opts.minDate = data.minDate;
    }
    if (data.maxDate) {
      opts.maxDate = data.maxDate;
    }

    return opts;
  };

  SS_DateTimePicker.prototype.buildDateTimePickerOptions = function() {
    var opts = {
      format: SS.convertDateTimeFormat(i18next.t("time.formats.picker")),
      closeOnDateSelect: true,
      scrollInput: false,
      roundTime: 'ceil',
      step: 30
    };

    var data = this.$el.data();
    if (data.format) {
      opts.format = data.format;
    }
    if (data.minDate) {
      opts.minDate = data.minDate;
    }
    if (data.maxDate) {
      opts.maxDate = data.maxDate;
    }
    if ("closeOnDateSelect" in data) {
      opts.closeOnDateSelect = data.closeOnDateSelect;
    }
    if ("scrollInput" in data) {
      opts.scrollInput = data.scrollInput;
    }
    // time specific options
    if (data.step) {
      opts.step = data.step;
    }
    if (data.roundTime) {
      opts.roundTime = data.roundTime;
    }

    return opts;
  };

  return SS_DateTimePicker;
})();
