Logs = new Meteor.Collection 'logs'
Settings = new Meteor.Collection 'settings'

Meteor.publish "all_logs", ()->
  Logs.find()

Meteor.publish "all_settings", ()->
  Settings.find()

Settings.allow
  insert: ()->
    return true
  update: ()->
    return true
  remove: ()->
    return true