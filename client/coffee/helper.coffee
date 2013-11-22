# HELPER FUNCTIONS
Template.home.logs = ()->
  searchString = Session.get('search_keywords')  
  searchArr = searchString.split(',') if searchString?  
  selector = {}
  if searchArr? and _.compact(searchArr).length > 0
    keywordArr = []  
    for word in searchArr
      word = word.trim().replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, "\\$&")
      patWord = new RegExp(word, 'i')
      keywordArr.push {rawLine: patWord}    
    selector = { $and: keywordArr }
  return Logs.find( selector ,{sort: {incomeMillis: -1}})
Template.home.getDate = (mills)->
  date = new Date(mills)
  return date.toISOString()

Template.home.homeLoading = ()->
  return Session.get('home.loading')

Template.home.getLvlClass = (lvl)->
  if lvl.trim() is "INFO"
    result = "lvlInfo"
  else
    if lvl.trim() is "WARNING"
      result = "lvlWarning"
    else
      if lvl.trim() is "ERROR"
        result = "lvlError"
      else
        if lvl.trim() is 'info'
          result = "lvlInfo"
        else
          if lvl.trim() is 'warning'
            result = 'lvlWarning'
          else
            if lvl.trim() is 'error'
              result = 'lvlError'
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