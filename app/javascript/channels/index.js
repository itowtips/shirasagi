// Import all the channels to be used by Action Cable

import consumer from "./consumer"

window.appRoom = consumer.subscriptions.create({ channel: "ChatChannel" }, {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    $(data["html"]).appendTo(".messages").hide().show('fast');
  },

  speak: function(message) {
    return this.perform('speak', { message: message });
  }
});
