this.SS_ImageViewer = (function () {
  function SS_ImageViewer() {}

  SS_ImageViewer.options = {};
  SS_ImageViewer.viewer = {};

  SS_ImageViewer.render = function (options) {
    var default_options = { prefixUrl: "/assets/js/openseadragon/images/" };
    SS_ImageViewer.options = $.extend(default_options, options)
    SS_ImageViewer.viewer = OpenSeadragon(SS_ImageViewer.options);
    return SS_ImageViewer.viewer;
  };

  return SS_ImageViewer;
})();
