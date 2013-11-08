Logs = new Meteor.Collection 'logs'
Settings = new Meteor.Collection 'settings'

Meteor.publish "all_logs", ()->
  Logs.find()
Meteor.publish "all_settings", ()->
  Logs.find()