###
Not documented yet
###

_data = {}
_currentLayoutData = {}

_wasLandscape = null
_tableView = null
isAndroid = Titanium.Platform.name == 'android'

exports.createView = (data) ->
  ###
  data
    .menuData = menuData
    .top
    .left
    .right
    .bottom
    .menu
      .width
      .hiddenWidth

  ###
  isLandscape()

  _data = data

  view = Ti.UI.createView
    top:              data.top || 0
    bottom:           data.bottom || 0
    left:             data.left || 0
    right:            data.right || 0
    backgroundColor: '#e0e0e0'

  view.add leftMenu data.menuData, view
  view.dataContainer = null

  view

isLandscape = (o) ->
  return Ti.Gesture.getLandscape() if isAndroid
  unless o?
    o = Ti.Gesture.getOrientation()

  if o in [Ti.UI.PORTRAIT, Ti.UI.UPSIDE_PORTRAIT, Ti.UI.LANDSCAPE_LEFT, Ti.UI.LANDSCAPE_RIGHT]
    return _wasLandscape = o in [Ti.UI.LANDSCAPE_LEFT, Ti.UI.LANDSCAPE_RIGHT]
  else
    # If orientation is unclear, return the previous one
    return _wasLandscape

_displayCapsHolder = null
displayCaps = (type) ->
  unless _displayCapsHolder?
    landscape = isLandscape()
    _displayCapsHolder =
      width:    if landscape then Ti.Platform.displayCaps.getPlatformHeight() else Ti.Platform.displayCaps.getPlatformWidth()
      height:   if landscape then Ti.Platform.displayCaps.getPlatformWidth() else Ti.Platform.displayCaps.getPlatformHeight()

  switch type
    when 1,'width','x'
      return _displayCapsHolder.width
    when 2,'height','y'
      return _displayCapsHolder.height

  return _displayCapsHolder

convertPointForOrientation = (points, orientation) ->

  xValue = points.x
  yValue = points.y

  switch orientation
    when Ti.UI.UPSIDE_PORTRAIT
      yValue = displayCaps('height') - yValue
      xValue = displayCaps('width') - xValue
    when Ti.UI.LANDSCAPE_LEFT
      x = displayCaps('height') - yValue
      y = xValue
      yValue = y
      xValue = x
    when Ti.UI.LANDSCAPE_RIGHT
      x = yValue
      y = displayCaps('width') - xValue
      yValue = y
      xValue = x

  return {
    x: xValue
    y: yValue
  }
exports.activate = (id) ->
  _tableView.selectRow id
  _tableView.fireEvent 'click',
    index: id
    rowData:
      menuInfo: _data.menuData[id]

leftMenu = (menuData, parentView) ->
  view = Ti.UI.createView()

  tableData = []
  for menuInfo in menuData
    tbvRow = Ti.UI.createTableViewRow
      title: menuInfo.name
      height: 70
      menuInfo: menuInfo
      color: '#292929'

    if menuInfo.icon?
      tbvRow.leftImage = "/skin/images/icons/#{menuInfo.icon}"

    tbvRow.add Ti.UI.createView
      height: 1
      bottom: 0
      left: 5
      right: 5
      backgroundColor :'#CCC'
      opacity: 0.4

    tableData.push tbvRow

  view.add Ti.UI.createView
    backgroundImage:'/skin/images/menu_background_150x822.png'
    left: 0
    width: _data.menu.width

  view.add tableView = Ti.UI.createTableView
    data: tableData
    allowsSelection: true
    left: 0
    width: if _data.menu.width > 0 then _data.menu.width else (if _data.menu.hiddenWidth? then _data.menu.hiddenWidth else 200)
    selectionId: -1
    style:Titanium.UI.iPhone.TableViewStyle.PLAIN
    separatorStyle: Ti.UI.iPhone.TableViewSeparatorStyle.NONE
    backgroundColor:'transparent'
    contentOffset:
      x: 0
      y: 0

  view.add shadowRight = Ti.UI.createView
    backgroundImage: '/skin/images/shadow_right.png'
    width: 15
    left: if _data.menu.width > 0 then _data.menu.width else (if _data.menu.hiddenWidth? then _data.menu.hiddenWidth else 200)
    zIndex: 2

  _tableView = tableView
  tableView.addEventListener 'scrollEnd', (e) ->
    tableView.contentOffset = e.contentOffset
  tableView.addEventListener 'click', (e) ->
    return if e.index is tableView.selectionId
    view.add loaderBar = Ti.UI.createView
      height: 70
      width: 5
      backgroundColor: '#54b4f2'
      left: if _data.menu.width > 0 then _data.menu.width else (if _data.menu.hiddenWidth? then _data.menu.hiddenWidth else 200)
      top: e.index * 70 + 5 - tableView.contentOffset.y
      zIndex: 1

    closeDataContainer parentView
    loaderBar.animate
      width: (if isLandscape() then displayCaps('height') - _data.menu.width else displayCaps('width') - _data.menu.width)
      duration: 300
    , ->
      tableView.selectionId = e.index
      loadViewInDataContainer parentView, e.rowData.menuInfo.view, view
      view.remove loaderBar
      loaderBar = null

  view

closeDataContainer = (parentView) ->
  if parentView.dataContainer?
    parentView.dataContainer.close()
    parentView.dataContainer = null

exports.open = (parentView, dataContainer) ->
  loadViewInDataContainer parentView, dataContainer

loadViewInDataContainer = (parentView, dataContainer) ->
  closeDataContainer parentView

  dataContainer.top = _data.offsetTop
  dataContainer.dragAllowed = true
  dataContainer.dataContainer = null
  dataContainer.parentView = parentView

  dataContainer.addEventListener 'close', (e) ->
    Ti.Gesture.removeEventListener 'orientationchange', updateLayout
    dataContainer.dataContainer.close() if dataContainer.dataContainer?

  viewWidth = (if isLandscape() then displayCaps('height') else displayCaps('width'))

  if dataContainer.isHalf? and dataContainer.isHalf is true
    dataContainer.left= viewWidth
    dataContainer.width= (viewWidth - _data.menu.width) / 2
  else
    dataContainer.left= viewWidth
    dataContainer.width= viewWidth - _data.menu.width

  dataContainer.open()

  dataContainer.animate
    left: (_data.menu.width + (if dataContainer.isHalf? and dataContainer.isHalf is true then (viewWidth - _data.menu.width) / 2 else 0)) - 30
    duration: 200
  , ->
    dataContainer.animate
      left: (_data.menu.width + (if dataContainer.isHalf? and dataContainer.isHalf is true then (viewWidth - _data.menu.width) / 2 else 0))
      duration: 100

  attachEvents dataContainer
  parentView.dataContainer = dataContainer
  updateLayout = (e) ->
    _updateLayout dataContainer, isLandscape(e.orientation)

  Ti.Gesture.addEventListener 'orientationchange', updateLayout

_updateLayout = (dataContainer, landscape) ->
  viewWidth = if landscape then displayCaps('height') else displayCaps('width')


  if dataContainer.isSticked? and dataContainer.isSticked is true

    dataContainer.left= (if _data.menu.hiddenWidth? then _data.menu.hiddenWidth else 200)
  else
    dataContainer.left= (_data.menu.width + (if dataContainer.isHalf? and dataContainer.isHalf is true then (viewWidth - _data.menu.width) / 2 else 0))

  if dataContainer.isHalf? and dataContainer.isHalf
    dataContainer.width= (viewWidth - _data.menu.width) / 2
  else
    dataContainer.width= (viewWidth - _data.menu.width)

attachEvents = (dataContainer) ->
  swipeDetection = null
  swipeTimer = null
  dataContainer.addEventListener 'swipe', (e) ->
    swipeDetection = e
    swipeTimer = setTimeout ->
      swipeDetection = null
    , 150


  dataContainer.addEventListener 'touchstart', (e) ->
    return unless e.source.dragAllowed?
    e.source.originLeft = e.x
    e.source.originTop = e.y
    e.source.orientation = Ti.UI.orientation

  dataContainer.addEventListener 'touchmove', (e) ->
    return unless e.source.dragAllowed?

    points =
      x: e.globalPoint.x
      y: e.globalPoint.y

    points = convertPointForOrientation points, e.source.orientation

    dataContainer.animate
      left: points.x - e.source.originLeft
      duration: 1

  dataContainer.addEventListener 'touchcancel', (e) ->
    viewWidth = (if isLandscape() then displayCaps('height') else displayCaps('width'))
    dataContainer.animate
        left: _data.menu.width + (if dataContainer.isHalf? and dataContainer.isHalf is true then (viewWidth - _data.menu.width) / 2 else 0)
        duration: 200
      , ->
        dataContainer.left = _data.menu.width + (if dataContainer.isHalf? and dataContainer.isHalf is true then (viewWidth - _data.menu.width) / 2 else 0)

  dataContainer.addEventListener 'touchend', (e) ->
    return unless e.source.dragAllowed?

    points =
      x: e.globalPoint.x
      y: e.globalPoint.y

    points = convertPointForOrientation points, e.source.orientation

    viewWidth = (if isLandscape() then displayCaps('height') else displayCaps('width'))
    if ((swipeDetection? and swipeDetection.direction is 'right') or (e.globalPoint.x - e.source.originLeft > viewWidth - 80)) and dataContainer.closable? and dataContainer.closable is true
      clearTimeout swipeTimer
      dataContainer.animate
        left: viewWidth
        duration: 200
      , ->
        dataContainer.parentView.dataContainer = null
        dataContainer.close()
    else if (dataContainer.isStickable? and dataContainer.isStickable is true) and ((if _data.menu.hiddenWidth? then _data.menu.hiddenWidth else 200) - 50) <= (points.x - e.source.originLeft)
      dataContainer.isSticked = true
      dataContainer.left = points.x - e.source.originLeft
      dataContainer.animate
        left: (if _data.menu.hiddenWidth? then _data.menu.hiddenWidth else 200)
        duration: 200
      , ->
        dataContainer.left = (if _data.menu.hiddenWidth? then _data.menu.hiddenWidth else 200)
    else
      dataContainer.isSticked = false
      dataContainer.left = points.x - e.source.originLeft
      dataContainer.animate
        left: _data.menu.width + (if dataContainer.isHalf? and dataContainer.isHalf is true then (viewWidth - _data.menu.width) / 2 else 0)
        duration: 200
      , ->
        dataContainer.left = _data.menu.width + (if dataContainer.isHalf? and dataContainer.isHalf is true then (viewWidth - _data.menu.width) / 2 else 0)
