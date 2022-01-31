this.Gws_Schedule_Plan = (function () {
  function Gws_Schedule_Plan(el) {
    this.$el = $(el);

    this.$datetimeStartEl = this.$el.find(".datetime.start");
    this.$datetimeEndEl = this.$el.find(".datetime.end");
    this.$dateStartEl = this.$el.find(".date.start");
    this.$dateEndEl = this.$el.find(".date.end");
    this.$allday = this.$el.find('#item_allday');

    this.render();
  }

  Gws_Schedule_Plan.renderForm = function () {
    $(".gws-schedule-start-end-combo").each(function() { new Gws_Schedule_Plan(this) });
  };

  Gws_Schedule_Plan.prototype.isAllDay = function() {
    return this.$allday.prop('checked');
  };

  Gws_Schedule_Plan.prototype.render = function() {
    var self = this;

    var promises = [];
    if (self.$datetimeStartEl[0] && self.$datetimeEndEl[0]) {
      var d1 = $.Deferred();
      new Gws_Schedule_StartEndSynchronizer(self.$datetimeStartEl, self.$datetimeEndEl, function() { d1.resolve() });
      promises.push(d1.promise());
    }
    if (self.$dateStartEl[0] && self.$dateEndEl[0]) {
      var d2 = $.Deferred();
      new Gws_Schedule_StartEndSynchronizer(self.$dateStartEl, self.$dateEndEl, function() { d2.resolve() });
      promises.push(d1.promise());
    }

    self.$allday.on("change", function () {
      self.changeDateValue();
      self.changeDateForm();
    });
    self.changeDateForm();

    // ToDo の start_at と start_on は "hidden" になっていて、それぞれ end_at と end_on と同期させる
    if (self.$datetimeStartEl.attr("type") == "hidden") {
      SS_DateTimePicker.on(self.$datetimeEndEl, "changeDateTime", function () {
        self.copyEndToStart()
      });
    }
    if (self.$dateStartEl.attr("type") == "hidden") {
      SS_DateTimePicker.on(self.$dateEndEl, "changeDateTime", function () {
        self.copyEndToStart()
      });
    }

    if (promises.length > 0) {
      $.when.apply($, promises).done(function() { self.$el.trigger("ss:initialized"); });
    } else {
      self.$el.trigger("ss:initialized");
    }
  };

  Gws_Schedule_Plan.prototype.changeDateValue = function() {
    var self = this;

    if (self.isAllDay()) {
      self.copyDatetimeToDate();
    } else {
      self.copyDateToDatetime();
    }
  };

  Gws_Schedule_Plan.prototype.copyDatetimeToDate = function() {
    var stime = SS_DateTimePicker.momentValue(this.$datetimeStartEl);
    var etime = SS_DateTimePicker.momentValue(this.$datetimeEndEl);
    SS_DateTimePicker.momentValue(this.$dateStartEl, stime);
    SS_DateTimePicker.momentValue(this.$dateEndEl, etime);
  };

  Gws_Schedule_Plan.prototype.copyDateToDatetime = function() {
    var stime = SS_DateTimePicker.momentValue(this.$dateStartEl);
    var etime = SS_DateTimePicker.momentValue(this.$dateEndEl);

    var currentStartTime = SS_DateTimePicker.momentValue(this.$datetimeStartEl);
    var currentEndTime = SS_DateTimePicker.momentValue(this.$datetimeEndEl);

    if (stime && currentStartTime) {
      stime.hours(currentStartTime.hours());
      stime.minutes(currentStartTime.minutes());
    }
    if (etime && currentEndTime) {
      etime.hours(currentEndTime.hours());
      etime.minutes(currentEndTime.minutes());
    }
    SS_DateTimePicker.momentValue(this.$datetimeStartEl, stime);
    SS_DateTimePicker.momentValue(this.$datetimeEndEl, etime);
  };

  Gws_Schedule_Plan.prototype.changeDateForm = function () {
    if (this.isAllDay()) {
      this.$el.find('.dates-field').removeClass("hide");
      this.$el.find('.datetimes-field').addClass("hide");
    } else {
      this.$el.find('.dates-field').addClass("hide");
      this.$el.find('.datetimes-field').removeClass("hide");
    }
  };

  Gws_Schedule_Plan.prototype.copyEndToStart = function() {
    if (this.isAllDay()) {
      var date = SS_DateTimePicker.momentValue(this.$dateEndEl);
      SS_DateTimePicker.momentValue(this.$dateStartEl, date);
    } else {
      var time = SS_DateTimePicker.momentValue(this.$datetimeEndEl);
      SS_DateTimePicker.momentValue(this.$datetimeStartEl, time);
    }
  };

  return Gws_Schedule_Plan;

})();
