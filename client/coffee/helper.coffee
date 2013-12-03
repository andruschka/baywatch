# HELPER FUNCTIONS
@lvlClassesInfo = Meteor.settings.public.lvlClassesInfo
@lvlClassesWarning = Meteor.settings.public.lvlClassesWarning
@lvlClassesError = Meteor.settings.public.lvlClassesError
@dateSetting = Meteor.settings.public.timeStampFormat

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
  return Session.get('home.loading')

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
  
Template.chart.rendered = ()->
  # Log CHART
  ctx = $('#logChart').get(0).getContext('2d')
  data = {
  	labels : ["last 7h", "last 6h", "last 5h", "last 3h", "last 2h", "last 1h", "just now"],
  	datasets : [
  		{
  			fillColor : "rgba(151,187,205,0.5)",
  			strokeColor : "rgba(151,187,205,1)",
  			data : [70,50,100,20,14,5,1]
  		}
  	]
  }
  new Chart(ctx).Line(data)

  # Sys CHART
  ctx = $('#sysChart').get(0).getContext('2d')
  data = [{value: 30,	color:"#F7464A"},{value : 50,color : "#E2EAE9"},{value : 100,	color : "#D4CCC5"},{value : 40,	color : "#949FB1"},{value : 120,	color : "#4D5360"}]
  new Chart(ctx).Pie(data)