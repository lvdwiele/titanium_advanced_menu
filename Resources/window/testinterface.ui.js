(function() {
  var bodyView, headerView, ui;

  capp.code.testinterface.ui = ui = {};

  ui.createWindow = function(data) {
    var win;
    win = Ti.UI.createWindow({
      title: L('testinterface'),
      backgroundColor: '#FFF'
    });
    win.add(headerView());
    win.add(bodyView(data.menuData));
    Ti.Gesture.addEventListener('orientationchange', function(e) {});
    return win;
  };

  headerView = function() {
    var view;
    view = Ti.UI.createView({
      top: 0,
      height: 200,
      backgroundColor: '#444',
      backgroundImage: '/skin/images/top_background_768x200.png'
    });
    return view;
  };

  bodyView = function(menuData) {
    var data, view;
    view = Ti.UI.createView({
      top: capp.os({
        ipad: 200,
        iphone: 0
      }),
      bottom: 0,
      backgroundColor: '#e0e0e0'
    });
    data = {
      offsetTop: capp.os({
        ipad: 200,
        iphone: 0
      }),
      menu: {
        hiddenWidth: capp.os({
          ipad: 200,
          iphone: 200
        }),
        width: capp.os({
          ipad: 200,
          iphone: 0
        })
      },
      menuData: menuData
    };
    view.add(capp.code.testinterface.advmenu.createView(data, view));
    view.dataContainer = null;
    return view;
  };

}).call(this);
