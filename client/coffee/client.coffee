@Logs = new Meteor.Collection 'logs'
@Settings = new Meteor.Collection 'settings'

Session.set('home.loading', true)

Meteor.subscribe 'all_logs', ()->
  Session.set('home.loading', false)  

  Meteor.subscribe 'all_settings', ()->
    injectPieChart()
    injectLineChart()    

Session.setDefault 'editSet', ''

# CHART-JS functions
injectPieChart = ()->
  pieColors = ["#F7464A", "#E2EAE9", "#949FB1", "#178eff", "#fff789", "#ff7fe2", "#7fff91", "#c1bcff", ]
  sysCount = {}
  logs = Logs.find()
  logs.forEach (log)->
    if log.parsed
      thisSys = log.parsed.system
      if _.has(sysCount, thisSys) is false
        sysCount["#{thisSys}"] = 1
      else
        sysCount["#{thisSys}"] += 1
    else
      thisSys = 'NA'
      if _.has(sysCount, thisSys) is false
        sysCount["#{thisSys}"] = 1
      else
        sysCount["#{thisSys}"] += 1

  # PIE CHART for system based log- count
  cnts = _.values sysCount
  console.log cnts
  pieData = []
  i = 0
  for cnt in cnts
    ins = {'color':pieColors[i], 'value': cnt}
    pieData.push ins
    i = i+1
  
  # inject chart
  pieCtx = $('#sysChart').get(0).getContext('2d')
  new Chart(pieCtx).Pie(pieData)

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
  console.log countData
  # inject chart
  lineCtx = $('#logChart').get(0).getContext('2d')
  new Chart(lineCtx).Line(lineData)