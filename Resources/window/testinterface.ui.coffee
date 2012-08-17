capp.code.testinterface.ui = ui = {}


###
Create the UI window
###
ui.createWindow = (data) ->

  win = Ti.UI.createWindow
    title:           L 'testinterface'
    backgroundColor: '#FFF'

  ###
  Create nice header :)
  ###
  win.add headerView()

  ###
  Create body view where the module will be loaded
  ###
  win.add bodyView data.menuData



  win

###
Header view
###
headerView = ->
  view = Ti.UI.createView
    top:  0
    height: 200
    backgroundColor: '#444'
    backgroundImage:'/skin/images/top_background_768x200.png'

  view


###
Create a view, specify top
###
bodyView = (menuData) ->
  view = Ti.UI.createView
    top: capp.os
      ipad: 200
      iphone: 0
    bottom: 0
    backgroundColor: '#e0e0e0'


  ###
  Set specific data that is used by the Module
  ###
  data =
    # top: 0
    # left: 0
    # right: 0
    # bottom: 0
    offsetTop: capp.os ### Because there is a header view, it is possible to set a top offset, it's neseccary for setting the correct window location ###
      ipad: 200
      iphone: 0
    menu:
      hiddenWidth: capp.os ### Hidden Width is when the menu.width is 0. The view will stick to the menu that is behind ###
        ipad: 200
        iphone: 200
      width: capp.os ### Width of the left menu ###
        ipad: 200
        iphone: 0
    menuData: menuData ### Important, set the menu data ###

  ###
  Add the Menu to the view
  ###
  view.add capp.code.testinterface.advmenu.createView data, view
  view.dataContainer = null


  view
