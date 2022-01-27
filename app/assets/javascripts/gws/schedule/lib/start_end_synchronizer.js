this.Gws_Schedule_StartEndSynchronizer = (function () {
  var defaultStartEndDifferenceInMillis = 1000 * 60 * 60;

  var calcDifference = function (start, end) {
    if (!start || !end) {
      return defaultStartEndDifferenceInMillis;
    }

    var diff = end.getTime() - start.getTime();
    if (diff < 0) {
      return 0;
    }
    return diff;
  };

  function Gws_Schedule_StartEndSynchronizer(startEl, endEl, callback) {
    this.$startEl = $(startEl);
    this.$endEl = $(endEl);
    this.difference = defaultStartEndDifferenceInMillis;

    this.render(callback);
  }

  Gws_Schedule_StartEndSynchronizer.prototype.render = function(callback) {
    var self = this;

    var handler = function() { self.calcDifference() };
    self.$startEl.on("click", handler);
    self.$endEl.on("click", handler);

    self.$startEl.datetimepicker({
      onChangeDateTime: function() { self.updateEndValue(); }
    });
    if (!self.$endEl.datetimepicker("getValue")) {
      setTimeout(function() {
        self.updateEndValue();
        if (callback) {
          callback();
        }
      }, 0);
    } else if (callback) {
      callback();
    }
  };

  Gws_Schedule_StartEndSynchronizer.prototype.calcDifference = function() {
    var self = this;

    var startValue = self.$startEl.datetimepicker("getValue");
    var endValue = self.$endEl.datetimepicker("getValue");
    self.difference = calcDifference(startValue, endValue);
  };

  Gws_Schedule_StartEndSynchronizer.prototype.updateEndValue = function() {
    var self = this;

    var endValue = self.$startEl.datetimepicker("getValue");
    if (!endValue) {
      return;
    }
    endValue = moment(endValue);
    if (!endValue.isValid()) {
      return;
    }

    endValue.add(self.difference, "milliseconds");
    self.$endEl.datetimepicker({ value: SS.formatTime(endValue, "picker") });
  };

  return Gws_Schedule_StartEndSynchronizer;
})();
