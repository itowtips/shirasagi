this.Cms_Site_Search_History = (function () {
  function Cms_Site_Search_History(selector) {
    this.selector = selector;
    this.keyword = $(selector).find('[name="s[keyword]"]');
    this.history = $(selector).find('.site-search-history');

    this.index = 0;
    this.indexLength = this.history.find("li").length;

    if (this.keyword.length > 0 && this.history.length > 0) {
      this.render();
    }
  };

  Cms_Site_Search_History.prototype.render = function () {
    var _this = this;
    this.keyword.on("focus", function(){
      _this.history.show();
    });
    this.keyword.on("blur", function(){
      _this.index = 0;
      _this.history.find("li").removeClass("selected");
      _this.history.hide();
    });
    this.history.find("a").on("mousedown", function(){
      _this.keyword.off("blur");
    });
    this.keyword.on("keydown", function(e) {
      if (e.which != 38 && e.which != 40) {
        return;
      }

      if (e.which == 38) {
        _this.index -= 1;
      }
      if (e.which == 40) {
        _this.index += 1;
      }
      if (_this.index > _this.indexLength) {
        _this.index = 1;
      } else if (_this.index <= 0) {
        _this.index = _this.indexLength;
      }
      _this.history.find("li").removeClass("selected");
      _this.history.find("li:nth-child(" + _this.index + ")").addClass("selected");
      _this.keyword.val(_this.history.find("li.selected a").data("value"));
    });
  };

  return Cms_Site_Search_History;

})();
