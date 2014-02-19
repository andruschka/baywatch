# HELPER FUNCTIONS
if Meteor.settings and Meteor.settings? and Meteor.settings.public and Meteor.settings.public?
  @lvlClassesInfo = Meteor.settings.public.lvlClassesInfo
  @lvlClassesWarning = Meteor.settings.public.lvlClassesWarning
  @lvlClassesError = Meteor.settings.public.lvlClassesError
  @dateSetting = Meteor.settings.public.timeStampFormat
else
  alert "PLEASE START BAYWATCH WITH THE STARTUP SCRIPT"

Template.home.logs = ()->
  searchString = Session.get('search_keywords')
  searchArr = searchString.split(',') if searchString?  
  selector = {}
  filter = {incomeMillis: -1}
  if searchArr? and _.compact(searchArr).length > 0
    keywordArr = []  
    for word in searchArr
      word = word.trim().replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, "\\$&")
      patWord = new RegExp(word, 'i')
      keywordArr.push {rawLine: patWord}    
    selector = { $and: keywordArr }
  return Logs.find( selector ,{sort: filter})

Template.home.getDate = (mills)->
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

Template.helper.settings = ()->
  return Settings.find()

Template.helper.which_span = (life)->
  if life is "1"
    span = "1 day"
  else
    if life is "7"
      span = "1 week"
    else
      if life is "31"
        span = "1 month"
      else if life is "365"
        span = "1 year"
      else
        span = "permanent"
  return span