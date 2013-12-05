@Logs = new Meteor.Collection 'logs'
@Settings = new Meteor.Collection 'settings'

Session.set('home.loading', true)

Meteor.subscribe 'all_logs', ()->
  Session.set('home.loading', false)
  injectChartjs()

Meteor.subscribe 'all_settings'

Session.setDefault 'editSet', ''


# Some client functions:

injectChartjs = ()->

  logs = Logs.find()
  colors = ["#F7464A", "#E2EAE9", "#949FB1"]

  # Pie Chart for system based log- count
  # get data from logs
  sys = {}
  logs.forEach (log)->
    if log.parsed
      thisSys = log.parsed.system
      if _.has(sys, thisSys) is false
        sys["#{thisSys}"] = 1
      else
        sys["#{thisSys}"] += 1
    else
      thisSys = 'NA'
      if _.has(sys, thisSys) is false
        sys["#{thisSys}"] = 1
      else
        sys["#{thisSys}"] += 1
  cnts= _.values sys
  sysDat = []
  i = 0
  for cnt in cnts
    ins = {'color':colors[i], 'value': cnt}
    sysDat.push ins
    i = i+1
  sysData = sysDat
  # inject chart
  sysCtx = $('#sysChart').get(0).getContext('2d')
  new Chart(sysCtx).Pie(sysData)
  
  
  # Line Chart for timestamp based log- count
  # Dummy data
  logData = 
    labels : ["last 7h", "last 6h", "last 5h", "last 3h", "last 2h", "last 1h", "just now"],
    datasets : [
        fillColor : "rgba(97,169,255,0.5)",
        strokeColor : "rgba(97,169,255,1)",
        data : [70,50,100,20,14,5,1]
    ]  
  # inject chart
  logCtx = $('#logChart').get(0).getContext('2d')
  new Chart(logCtx).Line(logData)