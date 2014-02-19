@Logs = new Meteor.Collection 'logs'
@Settings = new Meteor.Collection 'settings'

Session.set('limit', 30)
Session.set('homeLoading', true)
Session.setDefault('editSet', '')


Deps.autorun ->
  Meteor.subscribe 'all_logs', Session.get('limit'), ()->
    Session.set('homeLoading', false)
    injectChartHTML()
    
    Meteor.subscribe 'all_settings', ()->
      injectLineChart()
      setNoti(5)

$(window).scroll ()->
  if Session.get('homeLoading') is false
    if $(window).scrollTop() >= $(document).height() - $(window).height() - 10
      newLimit = Session.get('limit') + 50
      Session.set('limit', newLimit )
      console.log 'limit extended!'

@injectChartHTML = ()->
  cCont = $('#chartContainer')
  lChart = '<center><canvas id="logChart" width="1140" height="150"></canvas></center'
  sChart = '<center><canvas id="logChart" width="940" height="150"></canvas></center'
  unless $('#logChart')[0]?
    if $(window).width() < 1200
      cCont.append(sChart)
    else
      cCont.append(lChart)

injectLineChart = ()->
  # LINE CHART for timestamp based log- count
  lineStrokeColor = "rgba(97,169,255,1)"
  lineFillColor = "rgba(97,169,255,0.5)"
  lineLabels = ["~60m","~45m","~30m","~15m"]
  
  nowTs = new Date().getTime()
  
  col1Ts = nowTs - 900000
  col2Ts = col1Ts - 900000
  col3Ts = col2Ts - 900000
  col4Ts = col3Ts - 900000
  
  countData = []
  
  col1 = Logs.find({incomeMillis: {$lt: nowTs, $gt: col1Ts}}).count()
  countData.push col1
  col2 = Logs.find({incomeMillis: {$lt: col1Ts, $gt: col2Ts}}).count()
  countData.push col2
  col3 = Logs.find({incomeMillis: {$lt: col2Ts, $gt: col3Ts}}).count()
  countData.push col3
  col4 = Logs.find({incomeMillis: {$lt: col3Ts, $gt: col4Ts}}).count() 
  countData.push col4
  
  lineData = 
    labels : lineLabels,
    datasets : [
        fillColor : lineFillColor,
        strokeColor : lineStrokeColor,
        data : countData
    ]    
  # console.log countData
  # inject chart
  lineCtx = $('#logChart').get(0).getContext('2d')
  new Chart(lineCtx).Line(lineData)

setNoti = (num)->
  if navigator.userAgent.indexOf('Safari') != -1 and navigator.userAgent.indexOf('Chrome') == -1
    # its safari
    document.title = "Baywatch ("+num+")"
  else
    Tinycon.setBubble(num)
    document.title = "Baywatch ("+num+")"