function Gws_Schedule_Csv(el) {
  this.$el = $(el);
  this.$importMode = this.$el.find('#import_mode');
  this.$importLog = this.$el.find('.import-log');
}

Gws_Schedule_Csv.render = function (el) {
  var instance = new Gws_Schedule_Csv(el);
  instance.render();
  return instance;
};

Gws_Schedule_Csv.prototype.render = function () {
  var self = this;
  this.$el.find('.import-confirm').on("click", function(){
    self.$importMode.val('confirm');
  });
  this.$el.find('.import-save').on("click", function(){
    self.$importMode.val('save');
  });
  this.$el.find('#import_form').ajaxForm({
    beforeSubmit: function() {
      self.$importLog.html($('<span />', { class: "import-loading" }).html(i18next.t("ss.notice.uploading")));
      SS_AddonTabs.show('#import-result');
    },
    success: function(data, status) {
      self.renderResult(data);
    },
    error: function(xhr, status, error) {
      self.renderError(xhr, status, error);
    }
  });
//  this.$el.find('.download-csv-template').on("click", function() {
//    setTimeout(function() { self.showCsvDescription(); }, 0);
//    return true;
//  });
  this.$el.find('.show-csv-description').on("click", function() {
    self.showCsvDescription();
  });
}

Gws_Schedule_Csv.prototype.renderResult = function(data) {
  var log = this.$importLog;
  log.html('')

  if (data.messages) {
    log.append('<div class="mb-1">' + data.messages.join('<br />') + '</div>');
  }
  if (data.items) {
    var count = { exist: 0, entry: 0, saved: 0, error: 0 };
    var $thead = $("<thead />")
      .append($("<th />", { style: "width: 150px" }).html(i18next.t("mongoid.attributes.gws/schedule/planable.start_at")))
      .append($("<th />", { style: "width: 150px" }).html(i18next.t("mongoid.attributes.gws/schedule/planable.end_at")))
      .append($("<th />", { style: "width: 30%" }).html(i18next.t("mongoid.attributes.gws/schedule/planable.name")))
      .append($("<th />").html(i18next.t('gws/schedule.import.result')));

    var $tbody = $("<tbody />")
    $.each(data.items, function(i, item){
      if (item.result == 'exist') count.exist += 1;
      if (item.result == 'entry') count.entry += 1;
      if (item.result == 'saved') count.saved += 1;
      if (item.result == 'error') count.error += 1;

      var $tr = $("<tr />", { class: "import-" + item.result })
        .append($("<td />").html(SS.formatTime(item.start_at)))
        .append($("<td />").html(SS.formatTime(item.end_at)))
        .append($("<td />").html(item.name))
        .append($("<td />").html(item.messages.join('<br />')));
      $tbody.append($tr);
    });
    var $table = $('<table />', { class: "index mt-1" }).append($thead).append($tbody);

    var $tabs = $('<div class="mb-1" />');
    if (count.exist) {
      $tabs.append($('<span class="ml-2 import-exist"/>').html(i18next.t('gws/schedule.import.exist') + '(' + count.exist + ')'));
    }
    if (count.entry) {
      $tabs.append($('<span class="ml-2 import-entry"/>').html(i18next.t('gws/schedule.import.entry') + '(' + count.entry + ')'));
    }
    if (count.saved) {
      $tabs.append($('<span class="ml-2 import-saved"/>').html(i18next.t('gws/schedule.import.saved') + '(' + count.saved + ')'));
    }
    if (count.error) {
      $tabs.append($('<span class="ml-2 import-error"/>').html(i18next.t('gws/schedule.import.error') + '(' + count.error + ')'));
    }

    log.append($tabs).append($table);
  }
}

Gws_Schedule_Csv.prototype.renderError = function(xhr, status, error) {
  try {
    var errors = xhr.responseJSON;
    var msg = errors.join("\n");
    this.$importLog.html(msg);
  } catch (ex) {
    this.$importLog.html("Error: " + error);
  }
};

Gws_Schedule_Csv.prototype.showCsvDescription = function() {
  var href = this.$el.find('.show-csv-description').attr("href");
  $.colorbox({
    inline: true, href: href, width: "90%", height: "90%", fixed: true, open: true
  });
};
