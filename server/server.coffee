@Logs = new Meteor.Collection 'logs'
@Settings = new Meteor.Collection 'settings'

Meteor.publish "all_logs", (limit)->
  if limit and limit?
    logLimit = limit
  else
    logLimit = 30
  Logs.find({},{sort: {incomeMillis: -1}, limit: logLimit})
  

Meteor.publish "all_settings", ()->
  Settings.find()

Settings.allow
  insert: ()->
    return true
  update: ()->
    return true
  remove: ()->
    return true

# scheduled job for deleting logs
Meteor.startup ()->
  Meteor.setInterval ()->
    now = Date.now()
    Logs.remove({"parsed.destroyAt": {$lt: now} })
    # update unparsed logs with setting for 'unknown' logs
    defLifeSpan = Settings.findOne({'name':'unknown'}).life
    destroyAt = getDestroyAtMillis(defLifeSpan)
    Logs.update({'parsed.system':{$exists:false}}, {$set:{'parsed':{'system':'unknown','destroyAt':destroyAt}}}, {multi:true})
  , 60000
  unless Settings.findOne({name: "unknown"})
    Settings.insert({name: "unknown", life: "7"})

@getDestroyAtMillis = (life)->
  timestamp = new Date().getTime()
  if life is "1"
    destroyAt = timestamp + 86400000
  if life is "2"
    destroyAt = timestamp + (86400000*2)
  if life is "3"
    destroyAt = timestamp + (86400000*3)
  if life is "4"
    destroyAt = timestamp + (86400000*4)
  if life is "5"
    destroyAt = timestamp + (86400000*5)
  if life is "6"
    destroyAt = timestamp + (86400000*6)
  if life is "7"
    destroyAt = timestamp + 604800000
  if life is "31"
    destroyAt = timestamp + 2678400000
  if life is "365"
    destroyAt = timestamp + 31536000000
  if life is "-1"
    destroyAt = timestamp + 31536000000000