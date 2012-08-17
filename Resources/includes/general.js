(function() {
  var locale, osname;

  capp.code = {};

  capp.ui = {};

  locale = Ti.Platform.locale;

  osname = Ti.Platform.osname;

  capp.os = function(map) {
    var def;
    def = map.def || null;
    if (typeof map[osname] !== 'undefined') {
      if (typeof map[osname] === 'function') {
        return map[osname]();
      } else {
        return map[osname];
      }
    } else {
      if (typeof def === 'function') {
        return def();
      } else {
        return def;
      }
    }
  };

}).call(this);
