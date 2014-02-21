Template.chart.width = ()->
  if $(window).width() < 1200
    return 940
  else
    return 1140
    
@lineDataFromLogs = ()->
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
  logCollectionForChart = Logs.find( selector ,{sort: filter}).fetch() # data for charts
  if logCollectionForChart.length > 0
    maxIM = _.max logCollectionForChart, (log)->
      return log.incomeMillis
    minIM = _.min logCollectionForChart, (log)->
      return log.incomeMillis
    stepCount = Math.round(((maxIM.incomeMillis - minIM.incomeMillis) / 900000)) # leads to labels for x axis
    labels = []
    for step in [0..stepCount]
      hourOrMinute = "minutes"
      mins = step * 15
      if mins > 60
        hourOrMinute = "hours"
        mins = mins / 60
      labels.push "#{mins} #{hourOrMinute}"            
      
    labels = labels.reverse()
    systemNameArr = _.map logCollectionForChart, (log)->
      if log.parsed? and log.parsed.system?
        log.parsed.system
      else
        undefined
    systemNameArr = _.uniq(_.compact(systemNameArr))
    datasets = []
    for system in systemNameArr
      dataArr = []
      for step in [stepCount..0]
        nowTs = new Date().getTime()
        minTs = (nowTs - (step * 900000))
        maxTs = (nowTs - ((step - 1) * 900000))        
        console.log "Logs.find({'parsed.system': #{system}, incomeMillis: {$lt: #{maxTs}, $gt: #{minTs}}}).count()"
        count = Logs.find({'parsed.system': system, incomeMillis: {$lt: maxTs, $gt: minTs}}).count()          
        console.log new Date(minTs)
        console.log new Date(maxTs)
        console.log count        
        dataArr.push count
      datasets.push {
        fillColor : "rgba(97,169,#{_.random(0,255)},0.5)",
        strokeColor : "rgba(97,169,#{_.random(0,255)},1)",
        data : dataArr,
        name : system
      }
    lineData = 
      labels : labels,
      datasets : datasets       
    console.log lineData
    return lineData    
  else
    return undefined
Template.chart.data = ()->
  lineDataFromLogs()
Template.chart.rendered = ()->
  cntxt = this.find('#logChart').getContext('2d')
  data = lineDataFromLogs()
  if data? and cntxt?
    # console.log data
    new Chart(cntxt).Line(data)
  $(this.find('#chartContainer')).scrollToFixed
    marginTop: 51, 
    dontSetWidth: true,
    preFixed: ()->
      $('#chartContainer').addClass('shadowed')
    preUnfixed: ()->
      $('#chartContainer').removeClass('shadowed')
  undefined
# @injectChartHTML = ()->
#   cCont = $('#chartContainer')
#   lChart = '<center><canvas id="logChart" width="1140" height="150"></canvas></center>'
#   sChart = '<center><canvas id="logChart" width="940" height="150"></canvas></center>'
#   unless $('#logChart')[0]?
#     if $(window).width() < 1200
#       cCont.append(sChart)
#       injectLineChart()
#     else
#       cCont.append(lChart)
#       injectLineChart()

# @refreshChart = ()->
#   # LINE CHART for timestamp based log- count
#   lineStrokeColor = "rgba(97,169,255,1)"
#   lineFillColor = "rgba(97,169,255,0.5)"
#   lineLabels = ["~60m","~45m","~30m","~15m"]
#   
#   countData = harvestData()
#   
#   lineData = 
#     labels : lineLabels,
#     datasets : [
#         fillColor : lineFillColor,
#         strokeColor : lineStrokeColor,
#         data : countData
#     ]    
#   # console.log countData
#   # inject chart
#   lineCtx = $('#logChart').get(0).getContext('2d')
#   new Chart(lineCtx).Line(lineData)
#   $('#chartContainer').scrollToFixed
#     marginTop: 51, 
#     dontSetWidth: true,
#     preFixed: ()->
#       $('#chartContainer').addClass('shadowed')
#     preUnfixed: ()->
#       $('#chartContainer').removeClass('shadowed')
#   
# injectLineChart = ()->
#   # LINE CHART for timestamp based log- count
#   lineStrokeColor = "rgba(97,169,255,1)"
#   lineFillColor = "rgba(97,169,255,0.5)"
#   lineLabels = ["~60m","~45m","~30m","~15m"]
#   
#   countData = harvestData()
#   
#   lineData = 
#     labels : lineLabels,
#     datasets : [
#         fillColor : lineFillColor,
#         strokeColor : lineStrokeColor,
#         data : countData
#     ]    
#   # console.log countData
#   # inject chart
#   lineCtx = $('#logChart').get(0).getContext('2d')
#   new Chart(lineCtx).Line(lineData)
#   $('#chartContainer').scrollToFixed
#     marginTop: 51, 
#     dontSetWidth: true,
#     preFixed: ()->
#       $('#chartContainer').addClass('shadowed')
#     preUnfixed: ()->
#       $('#chartContainer').removeClass('shadowed')
#       
# harvestData = ()->
#   countData = []
# 
#   nowTs = new Date().getTime()
#   col1Ts = nowTs - 900000
#   col2Ts = col1Ts - 900000
#   col3Ts = col2Ts - 900000
#   col4Ts = col3Ts - 900000
#   
#   
#   col1 = Logs.find({incomeMillis: {$lt: nowTs, $gt: col1Ts}}).count()
#   console.log col1
#   countData.push col1
#   col2 = Logs.find({incomeMillis: {$lt: col1Ts, $gt: col2Ts}}).count()
#   countData.push col2
#   col3 = Logs.find({incomeMillis: {$lt: col2Ts, $gt: col3Ts}}).count()
#   countData.push col3
#   col4 = Logs.find({incomeMillis: {$lt: col3Ts, $gt: col4Ts}}).count() 
#   countData.push col4
# 
#   return countData.reverse()