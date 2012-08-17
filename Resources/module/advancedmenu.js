
/*
Not documented yet
*/


(function() {
  var attachEvents, closeDataContainer, convertPointForOrientation, displayCaps, isAndroid, isLandscape, leftMenu, loadViewInDataContainer, _currentLayoutData, _data, _displayCapsHolder, _tableView, _updateLayout, _wasLandscape;

  _data = {};

  _currentLayoutData = {};

  _wasLandscape = null;

  _tableView = null;

  isAndroid = Titanium.Platform.name === 'android';

  exports.createView = function(data) {
    /*
      data
        .menuData = menuData
        .top
        .left
        .right
        .bottom
        .menu
          .width
          .hiddenWidth
    */

    var view;
    isLandscape();
    _data = data;
    view = Ti.UI.createView({
      top: data.top || 0,
      bottom: data.bottom || 0,
      left: data.left || 0,
      right: data.right || 0,
      backgroundColor: '#e0e0e0'
    });
    view.add(leftMenu(data.menuData, view));
    view.dataContainer = null;
    return view;
  };

  isLandscape = function(o) {
    if (isAndroid) {
      return Ti.Gesture.getLandscape();
    }
    if (o == null) {
      o = Ti.Gesture.getOrientation();
    }
    if (o === Ti.UI.PORTRAIT || o === Ti.UI.UPSIDE_PORTRAIT || o === Ti.UI.LANDSCAPE_LEFT || o === Ti.UI.LANDSCAPE_RIGHT) {
      return _wasLandscape = o === Ti.UI.LANDSCAPE_LEFT || o === Ti.UI.LANDSCAPE_RIGHT;
    } else {
      return _wasLandscape;
    }
  };

  _displayCapsHolder = null;

  displayCaps = function(type) {
    var landscape;
    if (_displayCapsHolder == null) {
      landscape = isLandscape();
      _displayCapsHolder = {
        width: landscape ? Ti.Platform.displayCaps.getPlatformHeight() : Ti.Platform.displayCaps.getPlatformWidth(),
        height: landscape ? Ti.Platform.displayCaps.getPlatformWidth() : Ti.Platform.displayCaps.getPlatformHeight()
      };
    }
    switch (type) {
      case 1:
      case 'width':
      case 'x':
        return _displayCapsHolder.width;
      case 2:
      case 'height':
      case 'y':
        return _displayCapsHolder.height;
    }
    return _displayCapsHolder;
  };

  convertPointForOrientation = function(points, orientation) {
    var x, xValue, y, yValue;
    xValue = points.x;
    yValue = points.y;
    switch (orientation) {
      case Ti.UI.UPSIDE_PORTRAIT:
        yValue = displayCaps('height') - yValue;
        xValue = displayCaps('width') - xValue;
        break;
      case Ti.UI.LANDSCAPE_LEFT:
        x = displayCaps('height') - yValue;
        y = xValue;
        yValue = y;
        xValue = x;
        break;
      case Ti.UI.LANDSCAPE_RIGHT:
        x = yValue;
        y = displayCaps('width') - xValue;
        yValue = y;
        xValue = x;
    }
    return {
      x: xValue,
      y: yValue
    };
  };

  exports.activate = function(id) {
    _tableView.selectRow(id);
    return _tableView.fireEvent('click', {
      index: id,
      rowData: {
        menuInfo: _data.menuData[id]
      }
    });
  };

  leftMenu = function(menuData, parentView) {
    var menuInfo, shadowRight, tableData, tableView, tbvRow, view, _i, _len;
    view = Ti.UI.createView();
    tableData = [];
    for (_i = 0, _len = menuData.length; _i < _len; _i++) {
      menuInfo = menuData[_i];
      tbvRow = Ti.UI.createTableViewRow({
        title: menuInfo.name,
        height: 70,
        menuInfo: menuInfo,
        color: '#292929'
      });
      if (menuInfo.icon != null) {
        tbvRow.leftImage = "/skin/images/icons/" + menuInfo.icon;
      }
      tbvRow.add(Ti.UI.createView({
        height: 1,
        bottom: 0,
        left: 5,
        right: 5,
        backgroundColor: '#CCC',
        opacity: 0.4
      }));
      tableData.push(tbvRow);
    }
    view.add(Ti.UI.createView({
      backgroundImage: '/skin/images/menu_background_150x822.png',
      left: 0,
      width: _data.menu.width
    }));
    view.add(tableView = Ti.UI.createTableView({
      data: tableData,
      allowsSelection: true,
      left: 0,
      width: _data.menu.width > 0 ? _data.menu.width : (_data.menu.hiddenWidth != null ? _data.menu.hiddenWidth : 200),
      selectionId: -1,
      style: Titanium.UI.iPhone.TableViewStyle.PLAIN,
      separatorStyle: Ti.UI.iPhone.TableViewSeparatorStyle.NONE,
      backgroundColor: 'transparent',
      contentOffset: {
        x: 0,
        y: 0
      }
    }));
    view.add(shadowRight = Ti.UI.createView({
      backgroundImage: '/skin/images/shadow_right.png',
      width: 15,
      left: _data.menu.width > 0 ? _data.menu.width : (_data.menu.hiddenWidth != null ? _data.menu.hiddenWidth : 200),
      zIndex: 2
    }));
    _tableView = tableView;
    tableView.addEventListener('scrollEnd', function(e) {
      return tableView.contentOffset = e.contentOffset;
    });
    tableView.addEventListener('click', function(e) {
      var loaderBar;
      if (e.index === tableView.selectionId) {
        return;
      }
      view.add(loaderBar = Ti.UI.createView({
        height: 70,
        width: 5,
        backgroundColor: '#54b4f2',
        left: _data.menu.width > 0 ? _data.menu.width : (_data.menu.hiddenWidth != null ? _data.menu.hiddenWidth : 200),
        top: e.index * 70 + 5 - tableView.contentOffset.y,
        zIndex: 1
      }));
      closeDataContainer(parentView);
      return loaderBar.animate({
        width: (isLandscape() ? displayCaps('height') - _data.menu.width : displayCaps('width') - _data.menu.width),
        duration: 300
      }, function() {
        tableView.selectionId = e.index;
        loadViewInDataContainer(parentView, e.rowData.menuInfo.view, view);
        view.remove(loaderBar);
        return loaderBar = null;
      });
    });
    return view;
  };

  closeDataContainer = function(parentView) {
    if (parentView.dataContainer != null) {
      parentView.dataContainer.close();
      return parentView.dataContainer = null;
    }
  };

  exports.open = function(parentView, dataContainer) {
    return loadViewInDataContainer(parentView, dataContainer);
  };

  loadViewInDataContainer = function(parentView, dataContainer) {
    var updateLayout, viewWidth;
    closeDataContainer(parentView);
    dataContainer.top = _data.offsetTop;
    dataContainer.dragAllowed = true;
    dataContainer.dataContainer = null;
    dataContainer.parentView = parentView;
    dataContainer.addEventListener('close', function(e) {
      Ti.Gesture.removeEventListener('orientationchange', updateLayout);
      if (dataContainer.dataContainer != null) {
        return dataContainer.dataContainer.close();
      }
    });
    viewWidth = (isLandscape() ? displayCaps('height') : displayCaps('width'));
    if ((dataContainer.isHalf != null) && dataContainer.isHalf === true) {
      dataContainer.left = viewWidth;
      dataContainer.width = (viewWidth - _data.menu.width) / 2;
    } else {
      dataContainer.left = viewWidth;
      dataContainer.width = viewWidth - _data.menu.width;
    }
    dataContainer.open();
    dataContainer.animate({
      left: (_data.menu.width + ((dataContainer.isHalf != null) && dataContainer.isHalf === true ? (viewWidth - _data.menu.width) / 2 : 0)) - 30,
      duration: 200
    }, function() {
      return dataContainer.animate({
        left: _data.menu.width + ((dataContainer.isHalf != null) && dataContainer.isHalf === true ? (viewWidth - _data.menu.width) / 2 : 0),
        duration: 100
      });
    });
    attachEvents(dataContainer);
    parentView.dataContainer = dataContainer;
    updateLayout = function(e) {
      return _updateLayout(dataContainer, isLandscape(e.orientation));
    };
    return Ti.Gesture.addEventListener('orientationchange', updateLayout);
  };

  _updateLayout = function(dataContainer, landscape) {
    var viewWidth;
    viewWidth = landscape ? displayCaps('height') : displayCaps('width');
    if ((dataContainer.isSticked != null) && dataContainer.isSticked === true) {
      dataContainer.left = (_data.menu.hiddenWidth != null ? _data.menu.hiddenWidth : 200);
    } else {
      dataContainer.left = _data.menu.width + ((dataContainer.isHalf != null) && dataContainer.isHalf === true ? (viewWidth - _data.menu.width) / 2 : 0);
    }
    if ((dataContainer.isHalf != null) && dataContainer.isHalf) {
      return dataContainer.width = (viewWidth - _data.menu.width) / 2;
    } else {
      return dataContainer.width = viewWidth - _data.menu.width;
    }
  };

  attachEvents = function(dataContainer) {
    var swipeDetection, swipeTimer;
    swipeDetection = null;
    swipeTimer = null;
    dataContainer.addEventListener('swipe', function(e) {
      swipeDetection = e;
      return swipeTimer = setTimeout(function() {
        return swipeDetection = null;
      }, 150);
    });
    dataContainer.addEventListener('touchstart', function(e) {
      if (e.source.dragAllowed == null) {
        return;
      }
      e.source.originLeft = e.x;
      e.source.originTop = e.y;
      return e.source.orientation = Ti.UI.orientation;
    });
    dataContainer.addEventListener('touchmove', function(e) {
      var points;
      if (e.source.dragAllowed == null) {
        return;
      }
      points = {
        x: e.globalPoint.x,
        y: e.globalPoint.y
      };
      points = convertPointForOrientation(points, e.source.orientation);
      return dataContainer.animate({
        left: points.x - e.source.originLeft,
        duration: 1
      });
    });
    dataContainer.addEventListener('touchcancel', function(e) {
      var viewWidth;
      viewWidth = (isLandscape() ? displayCaps('height') : displayCaps('width'));
      return dataContainer.animate({
        left: _data.menu.width + ((dataContainer.isHalf != null) && dataContainer.isHalf === true ? (viewWidth - _data.menu.width) / 2 : 0),
        duration: 200
      }, function() {
        return dataContainer.left = _data.menu.width + ((dataContainer.isHalf != null) && dataContainer.isHalf === true ? (viewWidth - _data.menu.width) / 2 : 0);
      });
    });
    return dataContainer.addEventListener('touchend', function(e) {
      var points, viewWidth;
      if (e.source.dragAllowed == null) {
        return;
      }
      points = {
        x: e.globalPoint.x,
        y: e.globalPoint.y
      };
      points = convertPointForOrientation(points, e.source.orientation);
      viewWidth = (isLandscape() ? displayCaps('height') : displayCaps('width'));
      if ((((swipeDetection != null) && swipeDetection.direction === 'right') || (e.globalPoint.x - e.source.originLeft > viewWidth - 80)) && (dataContainer.closable != null) && dataContainer.closable === true) {
        clearTimeout(swipeTimer);
        return dataContainer.animate({
          left: viewWidth,
          duration: 200
        }, function() {
          dataContainer.parentView.dataContainer = null;
          return dataContainer.close();
        });
      } else if (((dataContainer.isStickable != null) && dataContainer.isStickable === true) && ((_data.menu.hiddenWidth != null ? _data.menu.hiddenWidth : 200) - 50) <= (points.x - e.source.originLeft)) {
        dataContainer.isSticked = true;
        dataContainer.left = points.x - e.source.originLeft;
        return dataContainer.animate({
          left: (_data.menu.hiddenWidth != null ? _data.menu.hiddenWidth : 200),
          duration: 200
        }, function() {
          return dataContainer.left = (_data.menu.hiddenWidth != null ? _data.menu.hiddenWidth : 200);
        });
      } else {
        dataContainer.isSticked = false;
        dataContainer.left = points.x - e.source.originLeft;
        return dataContainer.animate({
          left: _data.menu.width + ((dataContainer.isHalf != null) && dataContainer.isHalf === true ? (viewWidth - _data.menu.width) / 2 : 0),
          duration: 200
        }, function() {
          return dataContainer.left = _data.menu.width + ((dataContainer.isHalf != null) && dataContainer.isHalf === true ? (viewWidth - _data.menu.width) / 2 : 0);
        });
      }
    });
  };

}).call(this);
