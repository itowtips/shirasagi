this.Gws_Schedule_Plan = (function () {
  function Gws_Schedule_Plan() {
  }

  Gws_Schedule_Plan.defaultDiffOn = 1000 * 60 * 60;
  Gws_Schedule_Plan.diffOn = Gws_Schedule_Plan.defaultDiffOn;

  Gws_Schedule_Plan.renderForm = function () {
    this.relateDateForm();
    this.relateDateTimeForm();
  };

  Gws_Schedule_Plan.renderAlldayForm = function () {
    this.changeDateForm();
    return $('#item_allday').on("change", function () {
      Gws_Schedule_Plan.changeDateValue();
      Gws_Schedule_Plan.changeDateForm();
    });
  };
  // @example
  //   2015/09/29 00:00 => 2015/09/29
  //   2015/09/29 => 2015/09/29 00:00

  Gws_Schedule_Plan.changeDateValue = function () {
    var stime, etime;
    if ($('#item_allday').prop('checked')) {
      stime = $('#item_start_at').datetimepicker("getValue");
      etime = $('#item_end_at').datetimepicker("getValue");
      if (stime) {
        stime = moment(stime).format($('#item_start_on').data("format") || "YYYY/MM/DD");
      }
      if (etime) {
        etime = moment(etime).format($('#item_end_on').data("format") || "YYYY/MM/DD");
      }

      $('#item_start_on').datetimepicker({ value: stime });
      $('#item_end_on').datetimepicker({ value: etime });
    } else {
      stime = $('#item_start_on').datetimepicker("getValue");
      if (stime) {
        stime = moment(stime);
      }
      etime = $('#item_end_on').datetimepicker("getValue");
      if (etime) {
        etime = moment(etime);
      }

      var currentStartTime = $('#item_start_at').datetimepicker("getValue");
      if (currentStartTime) {
        currentStartTime = moment(currentStartTime);
      }
      var currentEndTime = $('#item_end_at').datetimepicker("getValue");
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
        stime = moment(stime).format($('#item_start_at').data("format") || "YYYY/MM/DD HH:mm");
      }
      if (etime) {
        etime = moment(etime).format($('#item_end_at').data("format") || "YYYY/MM/DD HH:mm");
      }
      $('#item_start_at').datetimepicker({ value: stime });
      $('#item_end_at').datetimepicker({ value: etime });
    }
  };

  Gws_Schedule_Plan.changeDateForm = function () {
    if ($('#item_allday').prop('checked')) {
      $('.dates-field').show();
      return $('.datetimes-field').hide();
    } else {
      $('.dates-field').hide();
      return $('.datetimes-field').show();
    }
  };

  Gws_Schedule_Plan.relateDateForm = function (startSelector, endSelector) {
    var $startEl = $(startSelector || '.date.start');
    var $endEl = $(endSelector || '.date.end');

    var calcDifference = function() {
      var startValue = $startEl.datetimepicker("getValue");
      var endValue = $endEl.datetimepicker("getValue");
      Gws_Schedule_Plan.diffOn = Gws_Schedule_Plan.diffDates(startValue, endValue);
    };
    $startEl.on("click", calcDifference);
    $endEl.on("click", calcDifference);

    var updateEndValue = function () {
      var endValue = $startEl.datetimepicker("getValue");
      if (!endValue) {
        return;
      }
      endValue = moment(endValue);
      if (!endValue.isValid()) {
        return;
      }

      endValue.add(Gws_Schedule_Plan.diffOn, "milliseconds");
      var format = $endEl.data("format") || 'YYYY/MM/DD HH:mm';
      $endEl.datetimepicker({ value: endValue.format(format) });
    };
    $startEl.datetimepicker({
      onChangeDateTime: updateEndValue
    });

    if (!$endEl.datetimepicker("getValue")) {
      setTimeout(updateEndValue, 0);
    }
  };

  Gws_Schedule_Plan.relateDateTimeForm = function () {
    return this.relateDateForm('.datetime.start', '.datetime.end');
  };

  Gws_Schedule_Plan.diffDates = function (src, dst) {
    if (!src || !dst) {
      return Gws_Schedule_Plan.defaultDiffOn;
    }

    var diff = dst.getTime() - src.getTime();
    if (diff < 0) {
      return 0;
    }
    return diff;
  };

  Gws_Schedule_Plan.transferEnd2Start = function () {
    var time;
    if ($('#item_allday').prop('checked')) {
      time = $('#item_end_on').datetimepicker("getValue");
      if (time) {
        time = moment(time);
        time = time.format($('#item_start_on').data("format"));
      }
      $('#item_start_on').datetimepicker({ value: time });
    } else {
      time = $('#item_end_at').datetimepicker("getValue");
      if (time) {
        time = moment(time);
        time = time.format($('#item_start_at').data("format"));
      }
      $('#item_start_at').datetimepicker({ value: time });
    }
  };

  return Gws_Schedule_Plan;

})();
