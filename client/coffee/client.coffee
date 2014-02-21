@Logs = new Meteor.Collection 'logs'
@Settings = new Meteor.Collection 'settings'

Session.set('limit', 30)
Session.set('homeLoading', true)
Session.setDefault('editSet', '')


Deps.autorun ->
  Meteor.subscribe 'all_logs', Session.get('limit'), ()->
    Session.set('homeLoading', false)
    
    Meteor.subscribe 'all_settings', ()->
      # injectChartHTML()
      # refreshChart()
      setNoti(0)

$(window).scroll ()->
  if Session.get('homeLoading') is false
    if $(window).scrollTop() >= $(document).height() - $(window).height() - 10
      newLimit = Session.get('limit') + 50
      Session.set('limit', newLimit )
    else
      Session.set('limit', 30 )
setNoti = (num)->
  if navigator.userAgent.indexOf('Safari') != -1 and navigator.userAgent.indexOf('Chrome') == -1
    # its safari
    document.title = "Baywatch ("+num+")"
  else
    Tinycon.setBubble(num)
    document.title = "Baywatch ("+num+")"