@Logs = new Meteor.Collection 'logs'
@Settings = new Meteor.Collection 'settings'

Session.set('home.loading', true)

Meteor.subscribe 'all_logs', ()->
  Session.set('home.loading', false)
  injectChartjs()

Meteor.subscribe 'all_settings'

Session.setDefault 'editSet', ''


# CHART-JS functions
injectChartjs = ()->

  pieColors = ["#F7464A", "#E2EAE9", "#949FB1"]
  lineStrokeColor = "rgba(97,169,255,1)"
  lineFillColor = "rgba(97,169,255,0.5)"
  lineLabels = ["last 7h", "last 6h", "last 5h", "last 3h", "last 2h", "last 1h", "just now"]

  logs = Logs.find()
  sysCount = {}
  timeStamps = []
  
  # loop through logs and collect data
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
    timeStamps.push log.incomeMillis

  # PIE CHART for system based log- count
  cnts = _.values sysCount
  pieData = []
  i = 0
  for cnt in cnts
    ins = {'color':pieColors[i], 'value': cnt}
    pieData.push ins
    i = i+1
  # inject chart
  pieCtx = $('#sysChart').get(0).getContext('2d')
  new Chart(pieCtx).Pie(pieData)
  
  # LINE CHART for timestamp based log- count
  # lineData =  [70,50,100,20,14,5,1]
  lineData =  []
  console.log timeStamps.length
  # console.log lineData
  # lineData = 
  #   labels : lineLabels,
  #   datasets : [
  #       fillColor : lineFillColor,
  #       strokeColor : lineStrokeColor,
  #       data : lineData
  #   ]  
  # # inject chart
  # lineCtx = $('#logChart').get(0).getContext('2d')
  # new Chart(lineCtx).Line(lineData)