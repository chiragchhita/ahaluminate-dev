(function() {
  angular.module('trPcApp', ['ngRoute', 'ngSanitize', 'ui.bootstrap', 'textAngular', 'trPcControllers']);

  angular.module('trPcControllers', []);

  angular.module('trPcApp').constant('NG_PC_APP_INFO', {
    version: '0.1.0'
  });

  angular.module('trPcApp').run([
    '$rootScope', function($rootScope) {
      var $embedRoot;
      return $embedRoot = angular.element('[data-embed-root]');
    }
  ]);

  angular.element(document).ready(function() {
    if (!angular.element(document).injector()) {
      return angular.bootstrap(document, ['trPcApp']);
    }
  });

}).call(this);
