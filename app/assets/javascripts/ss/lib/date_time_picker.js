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
    this.initialized = false;
    this.ee = new EventEmitter3();

    this.render();
    this.$el.data("ss_datetimepicker", this);
  }

  var initialized = false;

  SS_DateTimePicker.renderOnce = function () {
    if (initialized) {
      return;
    }

    $.datetimepicker.setLocale(document.documentElement.lang || 'ja');
    // setLocale() を呼び出すと dateFormatter がリセットされるので、setLocale() の後に setDateFormatter() を呼び出さなければならない。
    $.datetimepicker.setDateFormatter('moment');

    initialized = true;
  };

  SS_DateTimePicker.render = function (root, type) {
    SS_DateTimePicker.renderOnce();

    $(root || document).find(".js-date,.js-datetime").each(function () {
      var $this = $(this);
      var data = $this.data();
      if ("ss_datetimepicker" in data) {
        // already instantiated
        return;
      }

      new SS_DateTimePicker(this, type);
    });
  };

  SS_DateTimePicker.hasFormDataEvent = function () {
    if (SS.env === "test" && Math.random() < 0.5) {
      return false;
    }
    return !!window.FormDataEvent;
  };

  SS_DateTimePicker.replaceDateTimeValue = function (ev) {
    // You can use some ES6 features with ES5 syntax within this method.
    var form = ev.target;
    var formData = ev.originalEvent.formData;
    Array.from(new Set(formData.keys())).forEach(function (key) {
      var elements = form.elements[key];
      if ("forEach" in elements) {
        if (! $(elements[0]).data("ss_datetimepicker")) {
          return;
        }

        var values = [];
        elements.forEach(function (el) {
          var $el = $(el);
          var picker = $el.data("ss_datetimepicker")
          if (! picker) {
            values.push("");
            return;
          }

          values.push(picker.valueForExchange());
        });

        formData.delete(key);
        values.forEach(function (value) {
          formData.append(key, value)
        });
      } else {
        var $el = $(elements);
        var picker = $el.data("ss_datetimepicker");
        if (! picker) {
          return;
        }

        formData.set(key, picker.valueForExchange());
      }
    });
  };

  SS_DateTimePicker.instance = function (selector) {
    return $(selector).data("ss_datetimepicker");
  };

  [ "on", "once", "off", "momentValue", "valueForExchange" ].forEach(function(method) {
    SS_DateTimePicker[method] = function() {
      var selector = Array.prototype.shift.call(arguments)
      return SS_DateTimePicker.prototype[method].apply(SS_DateTimePicker.instance(selector), arguments);
    };
  });

  SS_DateTimePicker.prototype.render = function () {
    var self = this;

    var options = self.type === "date" ? self.buildDatePickerOptions() : self.buildDateTimePickerOptions();
    self.$el
      .attr('autocomplete', 'off')
      .datetimepicker(options);

    self.once("generate", function() { self.onInitialized(); });

    if (SS_DateTimePicker.hasFormDataEvent()) {
      var $form = this.$el.closest("form");
      if (!$form.data("ss-datetime-picker-installed")) {
        $form.data("ss-datetime-picker-installed", true);
        $form.on("formdata", SS_DateTimePicker.replaceDateTimeValue);
      }
    } else {
      self.createShadow();
    }
  };

  SS_DateTimePicker.prototype.on = function (_event, _callback, _context) {
    this.ee.on.apply(this.ee, arguments);
    // to be able to chain on, once and off
    return this;
  };

  SS_DateTimePicker.prototype.once = function (_event, _callback, _context) {
    this.ee.once.apply(this.ee, arguments);
    // to be able to chain on, once and off
    return this;
  };

  SS_DateTimePicker.prototype.off = function (_event, _callback, _context) {
    this.ee.removeListener.apply(this.ee, arguments);
    // to be able to chain on, once and off
    return this;
  };

  SS_DateTimePicker.prototype.onInitialized = function () {
    this.initialized = true;
  };

  SS_DateTimePicker.prototype.createShadow = function () {
    // IE11, old Safari, old Firefox, old Chrome goes here
    var self = this;

    var $shadow = $("<input />", {
      type: "hidden",
      class: "shadow",
      value: self.valueForExchange(),
      name: self.$el.attr("name")
    });
    $shadow.data("ss_datetimepicker", self);

    self.$el.removeAttr("name", "");
    $shadow.insertAfter(self.$el);
    self.$shadow = $shadow;

    self.on("changeDateTime", function() {
      self.updateShadow();
    });
  };

  SS_DateTimePicker.prototype.momentValue = function(value) {
    var self = this;

    if (arguments.length === 1) {
      // setter
      if (value) {
        value = self.type === "datetime" ? SS.formatTime(value, "picker") : SS.formatDate(value, "picker")
      }
      self.$el.val(value || '');
      self.$el.datetimepicker({ value: value || '' });
      // self.$el.datetimepicker("validate");
      // self.$el.trigger('change');

      self.updateShadow();
    } else {
      // getter
      // datetimepicker のバグだと思うが、初期化時に value が nil や空文字の場合、getValue がカレント時刻になってしまう。
      // 表示されている値（input の value)と、内部の値（datetimepicker の getValue）とが異なる場合を考慮する。
      if (!self.$el.val()) {
        return null;
      }

      var ret = self.$el.datetimepicker("getValue");
      if (!ret) {
        return ret;
      }

      return moment(ret);
    }
  };

  SS_DateTimePicker.prototype.valueForExchange = function () {
    var self = this;

    var value = self.momentValue();
    if (value) {
      value = value.format(this.type === "datetime" ? "YYYY/MM/DD HH:mm:ss" : "YYYY/MM/DD");
    }

    return value || '';
  };

  SS_DateTimePicker.prototype.updateShadow = function () {
    var self = this;
    if (!self.$shadow) {
      return;
    }

    self.$shadow.val(self.valueForExchange());
  };

  SS_DateTimePicker.prototype.buildDatePickerOptions = function () {
    var self = this;
    var opts = {
      format: SS.convertDateTimeFormat(i18next.t("date.formats.picker")),
      value: self.$el.val(),
      timepicker: false,
      closeOnDateSelect: true,
      scrollInput: false,
      onGenerate: function() { self.ee.emit("generate"); },
      onChangeDateTime: function(currentTime, $input, ev) { self.ee.emit("changeDateTime", currentTime, $input, ev); }
    };

    var data = self.$el.data();
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

  SS_DateTimePicker.prototype.buildDateTimePickerOptions = function () {
    var self = this;
    var opts = {
      format: SS.convertDateTimeFormat(i18next.t("time.formats.picker")),
      value: self.$el.val(),
      closeOnDateSelect: true,
      scrollInput: false,
      roundTime: 'ceil',
      step: 30,
      onGenerate: function() { self.ee.emit("generate"); },
      onChangeDateTime: function(currentTime, $input, ev) { self.ee.emit("changeDateTime", currentTime, $input, ev); }
    };

    var data = self.$el.data();
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
