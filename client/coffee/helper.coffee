# HELPER FUNCTIONS
if Meteor.settings and Meteor.settings? and Meteor.settings.public and Meteor.settings.public?
  @lvlClassesInfo = Meteor.settings.public.lvlClassesInfo
  @lvlClassesWarning = Meteor.settings.public.lvlClassesWarning
  @lvlClassesError = Meteor.settings.public.lvlClassesError
  @dateSetting = Meteor.settings.public.timeStampFormat
else
  alert "PLEASE START BAYWATCH WITH THE STARTUP SCRIPT"

Template.home.logs = ()->
  return Logs.find({}, {sort: {incomeMillis: -1}})

Template.home.getDate = (mills)->
  if mills?
    date = new Date(mills)
    if dateSetting.ISOString is true
      return date.toISOString()
    else
      if dateSetting.DateString is true
        return date.toString()
      else
        if dateSetting.LocaleString is true
          return date.toLocaleString()

Template.home.homeLoading = ()->
  return Session.get('homeLoading')

Template.home.getLvlClass = (lvl)->
  lvl = lvl.trim()
  isInfo = _.indexOf(lvlClassesInfo, lvl)
  isWarning = _.indexOf(lvlClassesWarning, lvl)
  isError = _.indexOf(lvlClassesError, lvl)
  if isInfo isnt -1
    result = "lvlInfo"
  else
    if isWarning isnt -1
      result = "lvlWarning"
    else
      if isError isnt -1
        result = "lvlError"
      else
        result = "lvlNA"
  return result

Template.settingsModal.settings = ()->
  return Settings.find()

UI.registerHelper 'which_span', (life)->
  if life is "1"
    span = "1 day"
  if life is "2"
    span = "2 days"
  if life is "3"
    span = "3 days"
  if life is "4"
    span = "4 days"
  if life is "5"
    span = "5 days"
  if life is "6"
    span = "6 days"
  if life is "7"
    span = "1 week"
  if life is "31"
    span = "1 month"
  if life is "365"
    span = "1 year"
  if life is "-1"
    span = "permanent"    
  return span

UI.registerHelper 'listMails', (emlArr)->
  if emlArr?
    return emlArr.join ' '

UI.registerHelper 'systemFilterVal', ()->
  if Session.get 'filter_systems'
    return Session.get 'filter_systems'

UI.registerHelper 'searchVal', ()->
  if Session.get 'search_keywords'
    return Session.get 'search_keywords'

Template.chart.getDate = (mills)->
  console.log mills
  if mills?
    date = new Date(mills)
    if dateSetting.ISOString is true
      return date.toISOString()
    else
      if dateSetting.DateString is true
        return date.toString()
      else
        if dateSetting.LocaleString is true
          return date.toLocaleString()
  else
    return 'loading...'

UI.registerHelper 'desktop', ()->
  if $(window).width() > 990
    return true
  else
    return false