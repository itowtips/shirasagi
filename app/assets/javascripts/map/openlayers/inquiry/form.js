this.Openlayers_Inquiry_Form = (function () {
  function Openlayers_Inquiry_Form(selector, options) {
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

    if (this.input.val()) {
      var loc = this.input.val().split(',');
      this.loc = [parseFloat(loc[0]), parseFloat(loc[1])];
    }
    this.render();
  };

  Openlayers_Inquiry_Form.prototype.render = function () {
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

  Openlayers_Inquiry_Form.prototype.loadMap = function () {
    var self = this;
    if (!self.map) {
      self.canvas.css('height','400px');
      self.map = new Openlayers_Map(self.canvas[0], self.options);
    }
  };

  Openlayers_Inquiry_Form.prototype.setLocation = function (loc) {
    var self = this;
    self.map.removeMarkers();
    self.map.renderMarkers([{ "loc": loc }]);
    self.map.resize();
    self.selector.find("input").val(loc[0] + "," + loc[1]);
  };

  return Openlayers_Inquiry_Form;
})();
