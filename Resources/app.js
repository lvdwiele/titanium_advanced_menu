(function() {
  var win;

  Ti.UI.setBackgroundColor('#000');

  this.capp = {};

  Ti.include('/includes/general.js');

  Ti.include('/window/testinterface.js');

  win = capp.code.testinterface.createWindow();

  win.open();

}).call(this);
