//= require i18next/dist/umd/i18next.js
//= require i18next-http-backend/i18nextHttpBackend.js
//= require_self

jQuery.holdReady(true);
i18next.use(i18nextHttpBackend).init({
  lng: 'ja',
  fallbackLng: [ 'en', 'ja' ],
  backend: {
    loadPath: '/assets/locales/{{lng}}/{{ns}}.json'
  }
}).then(function() {
  jQuery.holdReady(false);
});

$(function () {
  i18next.changeLanguage(document.documentElement.lang);
});
