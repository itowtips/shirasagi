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
      self.$datetimeEndEl.datetimepicker({
        onChangeDateTime: function () {
          self.copyEndToStart()
        }
      });
    }
    if (self.$dateStartEl.attr("type") == "hidden") {
      self.$dateEndEl.datetimepicker({
        onChangeDateTime: function () {
          self.copyEndToStart()
        }
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
    var stime = this.$datetimeStartEl.datetimepicker("getValue");
    var etime = this.$datetimeEndEl.datetimepicker("getValue");
    if (stime) {
      stime = SS.formatDate(stime, "picker");
    }
    if (etime) {
      etime = SS.formatDate(etime, "picker");
    }

    this.$dateStartEl.datetimepicker({ value: stime });
    this.$dateEndEl.datetimepicker({ value: etime });
  };

  Gws_Schedule_Plan.prototype.copyDateToDatetime = function() {
    var stime = this.$dateStartEl.datetimepicker("getValue");
    if (stime) {
      stime = moment(stime);
    }
    var etime = this.$dateEndEl.datetimepicker("getValue");
    if (etime) {
      etime = moment(etime);
    }

    var currentStartTime = this.$datetimeStartEl.datetimepicker("getValue");
    if (currentStartTime) {
      currentStartTime = moment(currentStartTime);
    }
    var currentEndTime = this.$datetimeEndEl.datetimepicker("getValue");
    if (currentEndTime) {
      currentEndTime = moment(currentEndTime);
    }

    if (stime && currentStartTime) {
      stime.hours(currentStartTime.hours());
      stime.minutes(currentStartTime.minutes());
    }
    if (etime && currentEndTime) {
      etime.hours(currentEndTime.hours());
      etime.minutes(currentEndTime.minutes());
    }
    if (stime) {
      stime = SS.formatTime(stime, "picker");
    }
    if (etime) {
      etime = SS.formatTime(etime, "picker");
    }
    this.$datetimeStartEl.datetimepicker({ value: stime });
    this.$datetimeEndEl.datetimepicker({ value: etime });
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
      var date = this.$dateEndEl.datetimepicker("getValue");
      if (date) {
        date = SS.formatDate(date, "picker");
      }
      this.$dateStartEl('#item_start_on').datetimepicker({ value: date });
    } else {
      var time = this.$datetimeEndEl.datetimepicker("getValue");
      if (time) {
        time = SS.formatTime(time, "picker");
      }
      this.$datetimeStartEl.datetimepicker({ value: time });
    }
  };

  return Gws_Schedule_Plan;

})();
