this.Gws_Presence_User = (function () {
  function Gws_Presence_User() {
  }

  Gws_Presence_User.render = function () {
    // selector
    $(document).on("click", function() {
      $(".presence-state-selector").hide();
        return true;
    });
    $(".presence-state-selector").on("click", function() {
      return false;
    });
    $(".presence-state-selector [data-value]").on("click", function() {
      var id = $(this).closest(".presence-state-selector").attr("data-id");
      var url = $(this).closest(".presence-state-selector").attr("data-url");
      var value = $(this).attr("data-value");
      $.ajax({
        url: url,
        type: "POST",
        data: {
          _method: 'put',
          authenticity_token: $('meta[name="csrf-token"]').attr('content'),
          presence_state: value,
        },
        success: function(data) {
          Gws_Presence_User.changedState(id, data);
          $(".presence-state-selector").hide();
        },
        error: function (xhr, status, error) {
          alert(xhr.responseJSON.join("\n"));
        },
      });
      return false;
    });
    $(".select-presence-state").on("click", function(){
      $(".presence-state-selector").hide();
      $(this).closest("td").find(".presence-state-selector").show();
      return false;
    });
    $(".select-presence-state").next(".presence_state").on("click", function(){
      $(this).prev(".select-presence-state").trigger('click');
      return false;
    });
    // ajax-text-field
    $(".ajax-text-field").on("click", function(){
      Gws_Presence_User.toggleForm(this);
      return false;
    });
    $(".ajax-text-field").next(".editicon").on("click", function(){
      $(this).prev(".ajax-text-field").trigger('click');
      return false;
    })
  };

  Gws_Presence_User.changedState = function (id, data) {
    var presence_state = data["presence_state"] || "none";
    var presence_state_label = data["presence_state_label"];
    var state = $("tr[data-id=" + id + "] .presence_state");
    var selector = $("tr[data-id=" + id + "] .presence-state-selector");

    state.removeClass();
    state.addClass('presence_state');
    state.addClass(presence_state);
    state.text(presence_state_label);

    selector.find("[data-value=" + presence_state + "] .selected-icon").css('visibility', 'visible');
    selector.find("[data-value!=" + presence_state + "] .selected-icon").css('visibility', 'hidden');
  }

  Gws_Presence_User.toggleForm = function (ele) {
    var state = $(ele).attr("data-tag-state");
    var original = $(ele).attr("data-original-tag");
    var form = $(ele).attr("data-form-tag");
    var value = $(ele).text() || $(ele).val();
    var name = $(form).attr("name");
    var id = $(form).attr("data-id");
    var url = $(form).attr("data-url");
    var errorOccurred = false;

    if (state == "original") {
      form = $(form);
      form.attr("data-original-tag", $(ele).attr("data-original-tag"));
      form.attr("data-form-tag", $(ele).attr("data-form-tag"));
      form.val(value);
      form.focusout(function (e) {
        if (errorOccurred) {
          return true;
        }
        var data = {
          _method: 'put',
          authenticity_token: $('meta[name="csrf-token"]').attr('content'),
        };
        data[name] = $(form).val();
        $.ajax({
          url: url,
          type: "POST",
          data: data,
          success: function(data) {
            $(form).val(data[name]);
            Gws_Presence_User.toggleForm(form);
          },
          error: function (xhr, status, error) {
            alert(xhr.responseJSON.join("\n"));
            errorOccurred = true;
          },
        });
        return false;
      });
      form.keypress(function (e) {
        if (e.which == 13) {
          var data = {
            _method: 'put',
            authenticity_token: $('meta[name="csrf-token"]').attr('content'),
          };
          data[name] = $(form).val();
          $.ajax({
            url: url,
            type: "POST",
            data: data,
            success: function(data) {
              $(form).val(data[name]);
              Gws_Presence_User.toggleForm(form);
            },
            error: function (xhr, status, error) {
              alert(xhr.responseJSON.join("\n"));
              errorOccurred = true;
            },
          });
          return false;
        }
      });
      var replaced = form.uniqueId();
      $(ele).replaceWith(form);
      $(replaced).focus();
    }
    else {
      original = $(original).text(value);
      original.attr("data-original-tag", $(ele).attr("data-original-tag"));
      original.attr("data-form-tag", $(ele).attr("data-form-tag"));
      original.on("click", function(){
        Gws_Presence_User.toggleForm(this);
        return false;
      });
      original.uniqueId();
      $(ele).replaceWith(original);
    }
  };

  return Gws_Presence_User;
})();
