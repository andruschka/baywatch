Template.chart.width = ()->
  if $(window).width() < 1200
    return 940
  else
    return 1140
    
@lineDataFromLogs = ()->
  logCollectionForChart = currentLogs().fetch()
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
        # console.log "Logs.find({'parsed.system': #{system}, incomeMillis: {$lt: #{maxTs}, $gt: #{minTs}}}).count()"
        count = Logs.find({'parsed.system': system, incomeMillis: {$lt: maxTs, $gt: minTs}}).count()          
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
    # console.log lineData
    return lineData    
  else
    return undefined

Template.chart.data = ()->
  lineDataFromLogs()

Template.chart.rendered = ()->
  cntxt = this.find('#logChart').getContext('2d')
  data = lineDataFromLogs()
  if data? and cntxt?
    console.log data
    new Chart(cntxt).Line(data)
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