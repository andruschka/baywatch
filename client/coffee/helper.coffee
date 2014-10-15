# HELPER FUNCTIONS
if Meteor.settings and Meteor.settings? and Meteor.settings.public and Meteor.settings.public?
  @lvlClassesInfo = Meteor.settings.public.lvlClassesInfo
  @lvlClassesWarning = Meteor.settings.public.lvlClassesWarning
  @lvlClassesError = Meteor.settings.public.lvlClassesError
  @dateSetting = Meteor.settings.public.timeStampFormat
else
  alert "PLEASE START BAYWATCH WITH THE STARTUP SCRIPT"

Template.registerHelper 'which_span', (life)->
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

Template.registerHelper 'listMails', (emlArr)->
  if emlArr?
    return emlArr.join ' '

Template.registerHelper 'systemFilterVal', ()->
  if Session.get 'filter_systems'
    return Session.get 'filter_systems'

Template.registerHelper 'searchVal', ()->
  if Session.get 'search_keywords'
    return Session.get 'search_keywords'

Template.registerHelper 'getDate', (mills)->
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

Template.registerHelper 'desktop', ()->
  if $(window).width() > 990
    return true
  else
    return false
