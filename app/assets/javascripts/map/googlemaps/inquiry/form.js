this.Googlemaps_Inquiry_Form = (function () {
  function Googlemaps_Inquiry_Form(selector, options) {
    if (!options) {
      options = {};
    }
    this.selector = $(selector);
    this.canvas = this.selector.find("#map-canvas");
    this.search = this.selector.find(".search-location");
    this.input = this.selector.find(".loc");
    this.options = options;
    this.map = null;
    this.loc = null;
    this.markers = null;

    if (this.input.val()) {
      var loc = this.input.val().split(',');
      this.loc = [parseFloat(loc[0]), parseFloat(loc[1])];
    }
    this.render();
  };

  Googlemaps_Inquiry_Form.prototype.render = function () {
    var self = this;
    var success = function (loc) {
      self.loadMap();
      self.setLocation(loc);
    };
    new Map_Geolocation(self.search, success);
    if (self.loc) {
      self.loadMap();
      self.setLocation(self.loc);
    }
  };

  Googlemaps_Inquiry_Form.prototype.loadMap = function () {
    var self = this;
    if (!self.map) {
      self.canvas.css('height','400px');
      self.map = Googlemaps_Map.load(self.canvas, self.options);
    }
  };

  Googlemaps_Inquiry_Form.prototype.setLocation = function (loc) {
    var self = this;
    if (self.markers) {
      $.each(self.markers, function() {
        this.marker.setMap(null);
      });
    }
    Googlemaps_Map.setMarkers([{ "loc": loc }], {});
    self.markers = Googlemaps_Map.markers;
    self.selector.find("input").val(loc[0] + "," + loc[1]);
  };

  return Googlemaps_Inquiry_Form;
})();
