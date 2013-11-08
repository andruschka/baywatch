Logs = new Meteor.Collection 'logs'
Settings = new Meteor.Collection 'settings'
Meteor.subscribe 'all_logs'
Meteor.subscribe 'all_settings'

Template.home.logs = ()->
  return Logs.find()

Template.home.getDate = (mills)->
  date = new Date(mills)
  return date.toString()

Template.navbar.events
  'click #searchGo' : (e)->
    e.preventDefault()
    tag = $('#search').val().trim()
    if tag? and tag isnt ""
      $('#search').val("")
      console.log tag
      result = Logs.find({}, {logs: tag})
    else
      alert "No empty search"
  'click #settingsGo' : (e)->
    e.preventDefault()
    $('#settings').fadeIn()
    $('#darken').fadeIn()
  'click #add-setting' : (e)->
    e.preventDefault()
    $('#new-setting').fadeIn()
    $('#darken').fadeIn()

Template.helper.events
  'click .close-panels' : (e)->
    e.preventDefault()
    $('.modal').fadeOut()
    $('#darken').fadeOut()