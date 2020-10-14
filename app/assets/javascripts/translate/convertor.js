this.Translate_Convertor = (function () {
  function Translate_Convertor() {};

  Translate_Convertor.convert = function (url, body, translateSourceId, translateTargetId, callback) {
    $.ajax({
      url: url,
      type: 'POST',
      data: {
        body: body,
        translate_source_id: translateSourceId,
        translate_target_id: translateTargetId
      },
      success: function(data) {
        if (data['notice']) {
          SS.notice(data['notice']);
        }
        callback(data['body']);
      },
      error: function(xhr, status, error) {
        console.log(["== Error =="].concat(error).join("\n"));
      }
    });
  };

  return Translate_Convertor;

})();
