# Temporary fix for chartJS -> switched to bar charts without showing time spans

Template.chart.width = ()->
  if $(window).width() < 1200
    return 940
  else
    return 1140

dataFromLogs= ()->
  allSettings = Settings.find()
  allLogs = currentLogs().fetch()
  systems = []
  logCounts = []

  allSettings.forEach (setting)->
    systems.push setting.name
  for system in systems
    count = Logs.find({'parsed.system':system}).count()
    logCounts.push count
  if allLogs? and allLogs.length > 0
    minTsLog = _.min allLogs, (log)->
      return log.incomeMillis
    minTs = minTsLog.incomeMillis
  data = {
    latestTs: minTs,
    dataStack: {
      labels : systems,
      datasets : [
        {
          fillColor : "rgba(97,169,220,0.5)",
          strokeColor : "rgba(97,169,120,1)",
          data : logCounts
        }
      ]
    }
  }
  return data

Template.chart.data = ()->
  dataFromLogs()

Template.chart.rendered = ()->
  data = dataFromLogs().dataStack
  cntxt = this.find('#logChart').getContext('2d')
  new Chart(cntxt).Bar data
  
  $('#chartContainer').scrollToFixed
    marginTop: 51, 
    dontSetWidth: true,
    spacerClass: 'space',
    preFixed: ()->
      $('#chartContainer').addClass('shadowed')
    preUnfixed: ()->
      $('#chartContainer').removeClass('shadowed')
  # fix for multiple scrolltofixed spacers because of rerendering chart template...
  $('.space').not(':first').remove();
  undefined
  
  
  
  # @lineDataFromLogs = ()->
  #   logCollectionForChart = currentLogs().fetch()
  #   if logCollectionForChart.length > 0
  #     maxIM = _.max logCollectionForChart, (log)->
  #       return log.incomeMillis
  #     minIM = _.min logCollectionForChart, (log)->
  #       return log.incomeMillis
  #     stepCount = Math.round(((maxIM.incomeMillis - minIM.incomeMillis) / 900000)) # leads to labels for x axis
  #     
  #     labels = []
  #     
  #     for step in [0..stepCount]
  #       hourOrMinute = "minutes"
  #       mins = step * 15
  #       if mins > 60
  #         hourOrMinute = "hours"
  #         mins = mins / 60
  #       labels.push "#{mins} #{hourOrMinute}"                  
  #     labels = labels.reverse()
  #     
  #     systemNameArr = _.map logCollectionForChart, (log)->
  #       if log.parsed? and log.parsed.system?
  #         log.parsed.system
  #       else
  #         undefined
  #     systemNameArr = _.uniq(_.compact(systemNameArr))
  #     
  #     datasets = []
  #     for system in systemNameArr
  #       dataArr = []
  #       for step in [stepCount..0]
  #         nowTs = new Date().getTime()
  #         minTs = (nowTs - (step * 900000))
  #         maxTs = (nowTs - ((step - 1) * 900000))        
  # 
  #         count = Logs.find({'parsed.system': system, incomeMillis: {$lt: maxTs, $gt: minTs}}).count()          
  #         dataArr.push count
  #       datasets.push {
  #         fillColor : "rgba(97,169,#{_.random(0,255)},0.5)",
  #         strokeColor : "rgba(97,169,#{_.random(0,255)},1)",
  #         data : dataArr,
  #         name : system
  #       }
  #     lineData = 
  #       labels : labels,
  #       datasets : datasets       
  #     # console.log lineData
  #     return lineData    
  #   else
  #     return undefined
  # 
  # Template.chart.rendered = ()->
  #   data = lineDataFromLogs()
  #   if data? and cntxt?
  #     console.log data
  #     new Chart(cntxt).Line(data)
  #   $('#chartContainer').scrollToFixed
  #     marginTop: 51, 
  #     dontSetWidth: true,
  #     spacerClass: 'space',
  #     preFixed: ()->
  #       $('#chartContainer').addClass('shadowed')
  #     preUnfixed: ()->
  #       $('#chartContainer').removeClass('shadowed')
  #   # fix for multiple scrolltofixed spacers because of rerendering chart template...
  #   $('.space').not(':first').remove();
  #   undefined
  