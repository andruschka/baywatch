@Logs = new Meteor.Collection 'logs'
@Settings = new Meteor.Collection 'settings'

Meteor.publish "all_logs", (limit, searchString, sysString)->
  selector = {}
  filter = {incomeMillis: -1}
  
  searchArr = searchString.split(',') if searchString?  
  if searchArr? and _.compact(searchArr).length > 0
    keywordArr = []  
    for word in searchArr
      word = word.trim().replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, "\\$&")
      patWord = new RegExp(word, 'i')
      keywordArr.push {rawLine: patWord}
    selector1 = {$and:keywordArr}

  sysArr = sysString.split(',') if sysString?  
  if sysArr? and _.compact(sysArr).length > 0
    syswordArr = []  
    for word in sysArr
      word = word.trim().replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, "\\$&")
      patWord = new RegExp(word, 'i')
      syswordArr.push {'parsed.system': patWord}
    selector2 = {$or:syswordArr}


  if limit and limit?
    logLimit = limit
  else
    logLimit = 30

  if selector1?
    selector = selector1
  if selector2?
    selector = selector2
  if selector1? and selector2?
    selector = {$and:[selector1,selector2]}  
  
  return Logs.find(selector, {sort: filter, limit: logLimit})
  

Meteor.publish "all_settings", ()->
  Settings.find()

Settings.allow
  insert: ()->
    return true
  update: ()->
    return true
  remove: ()->
    return true

Meteor.startup ()->  
  # scheduled job for deleting logs
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
  switch life
    when "1"
      destroyAt = timestamp + 86400000
    when "2"
      destroyAt = timestamp + (86400000*2)
    when "3"
      destroyAt = timestamp + (86400000*3)
    when "4"
      destroyAt = timestamp + (86400000*4)
    when "5"
      destroyAt = timestamp + (86400000*5)
    when "6"
      destroyAt = timestamp + (86400000*6)
    when "7"
      destroyAt = timestamp + 604800000
    when "31"
      destroyAt = timestamp + 2678400000
    when "365"
      destroyAt = timestamp + 31536000000
    when "-1"
      destroyAt = timestamp + 31536000000000
  return destroyAt