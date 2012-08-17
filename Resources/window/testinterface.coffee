capp.code.testinterface = {}

###
Global var for just counting the windows
###
_index = 1

###
Create window to load module and load demo menu data.

###
capp.code.testinterface.createWindow = ->
  capp.code.testinterface.advmenu = require('/module/advancedmenu')

  data = {}

  ###
  Add some demodata, at the moment the Window is already created and added to the menu
  ###
  data.menuData = [
    {name:'Calendar',   view: testWindow('#'+Math.floor(Math.random()*16777215).toString(16), false, false, true), icon: 'calender.png'}
    {name:'Leads',      view: testWindow '#'+Math.floor(Math.random()*16777215).toString(16), false, false, true}
    {name:'Accounts',   view: testWindow '#'+Math.floor(Math.random()*16777215).toString(16), false, false, true}
    {name:'Contacts',   view: testWindow '#'+Math.floor(Math.random()*16777215).toString(16), false, false, true}
    {name:'Quotes',     view: testWindow '#'+Math.floor(Math.random()*16777215).toString(16), false, false, true}
    {name:'Proposals',  view: testWindow '#'+Math.floor(Math.random()*16777215).toString(16), false, false, true}
    {name:'Invoices',   view: testWindow '#'+Math.floor(Math.random()*16777215).toString(16), false, false, true}

  ]

  ###
  Create the UI and pass the menu data
  See the testinterface.ui.coffee file
  ###
  win = capp.code.testinterface.ui.createWindow data


  win.addEventListener 'open', ->
    capp.code.testinterface.advmenu.activate 0

  win


###
Just a sample window to show some data :)
###
testWindow = (backgroundColor, closable, isHalf, isStickable) ->
  win = Ti.UI.createWindow
    backgroundColor: backgroundColor
    closable : closable
    isHalf: (if isHalf? then isHalf else false)
    isStickable: (if isStickable? then isStickable else false)

  win.add Ti.UI.createView
    width: 1
    left: 0
    backgroundColor: '#AAA'
  win.add Ti.UI.createView
    width: 1
    right: 0
    backgroundColor: '#AAA'


  win.add btn = Ti.UI.createButton
    title: 'Open New Window'
    width: 200
    right: 10
    bottom: 140
    parentWin: win


  win.add btnHalf = Ti.UI.createButton
    title: 'Open Half New Window'
    width: 200
    right: 10
    bottom: 100
    parentWin: win

  win.add Ti.UI.createLabel
    text: 'Name of the table'
    top: 10
    left: 20
    color: '#333'
    font:
      fontSize: 25
    touchEnabled: false

  win.add Ti.UI.createLabel
    text: "Details number #{_index++}"
    top: 38
    left: 20
    color: '#333'
    touchEnabled: false
    font:
      fontSize: 18

  createMapView win



  btn.addEventListener 'click', (e) -> capp.code.testinterface.advmenu.open win, testWindow '#'+Math.floor(Math.random()*16777215).toString(16), true, false
  btnHalf.addEventListener 'click', (e) -> capp.code.testinterface.advmenu.open win, testWindow '#'+Math.floor(Math.random()*16777215).toString(16), true, true

  win


###
Create the Map View functionality
###
createMapView = (win) ->

  win.add mapView = Ti.Map.createView
    left: 20
    height: 100
    top: 70
    right: 200
    borderRadius: 5
    borderWidth: 1
    borderColor: '#AAA'
    mapType: Titanium.Map.STANDARD_TYPE
    region:
      latitude:51.471948
      longitude:5.462136
      latitudeDelta:0.02
      longitudeDelta:0.02
    animate:true
    regionFit:true
    userLocation:true

  win.add mapViewOverlay = Ti.UI.createView
    left: 20
    height: 100
    top: 70
    right: 200
    borderRadius: 5

  win.add mapButton = Ti.UI.createButton
    right: 10
    bottom: 10
    title: 'X'
    width: 40
    height: 40
    visible: false
  mapViewOverlay.addEventListener 'click', ->
    mapViewOverlay.visible = false
    mapView.animate
      left: 0
      height: 822 - 85
      right: 0
      duration: 500
    mapView.borderRadius = 0
    mapButton.visible = true

  mapButton.addEventListener 'click', ->
    mapViewOverlay.visible = true
    mapView.animate
      left: 20
      height: 100
      right: 200
      duration: 500

    mapView.borderRadius = 5
    mapButton.visible = false


Ti.include(
  'testinterface.ui.js'
)
