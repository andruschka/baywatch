@Logs = new Meteor.Collection 'logs'
@Settings = new Meteor.Collection 'settings'

Session.setDefault('limit', 50)
Session.set('homeLoading', true)
Session.setDefault('search_keywords', '')
Session.setDefault('filter_systems', '')


Deps.autorun ->
  Meteor.subscribe 'all_logs', Session.get('limit'), Session.get('search_keywords'), Session.get('filter_systems'), ()->
    Session.set('homeLoading', false)
    Meteor.subscribe 'all_settings', ()->
      setNoti(0)

$(window).scroll ()->
  if $(window).scrollTop() >= $(document).height() - $(window).height() - 20
    newLimit = Session.get('limit') + 50
    Session.set('limit', newLimit )

setNoti = (num)->
  if num > 1
    if navigator.userAgent.indexOf('Safari') != -1 and navigator.userAgent.indexOf('Chrome') == -1
      # its safari
      document.title = "Baywatch ("+num+")"
    else
      Tinycon.setBubble(num)
      document.title = "Baywatch ("+num+")"
  else
    document.title = "Baywatch"

Router.configure 
  layoutTemplate: 'appLayout'

Router.map ()->
  this.route 'home' ,
    path: '/'
    template: 'home'
  this.route 'notFound' ,
    path: '*'