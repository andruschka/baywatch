@Logs = new Meteor.Collection 'logs'
@Settings = new Meteor.Collection 'settings'

Session.set('home.loading', true)

Meteor.subscribe 'all_logs', ()->
  Session.set('home.loading', false)

Meteor.subscribe 'all_settings'

Session.setDefault 'editSet', ''