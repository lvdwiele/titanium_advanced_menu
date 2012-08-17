capp.code = {};
capp.ui = {};

#OS, Locale, and Density specific branching helpers adapted from the Helium library
#for Titanium: http://github.com/kwhinnery/Helium
locale = Ti.Platform.locale;
osname = Ti.Platform.osname;

#
#  Branching logic based on OS
#
capp.os = (map) ->
  def = map.def||null; #default function or value
  if typeof map[osname] != 'undefined'
    if typeof map[osname] == 'function'
       return map[osname]()
    else
      return map[osname]
  else
    if typeof def == 'function'
      return def()
    else
      return def


