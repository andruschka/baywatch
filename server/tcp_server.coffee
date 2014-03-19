if Meteor.settings?
  _config_ = Meteor.settings.tcpServer
  HOST = _config_.HOST
  PORT = _config_.PORT

rgxSystem = new RegExp(/\s[A-Za-z]*:\s/)

if _config_.enabled? and _config_.enabled is true
  Fiber = Meteor.require 'fibers'
  net = Meteor.require 'net'
  carrier = Meteor.require 'carrier'
  
  net.createServer (sock)->
    console.log 'SERVER CONNECTED TO : ' + sock.remoteAddress + ':'+ sock.remotePort

    carrier.carry sock, (line)->
      Fiber ()->
        line = line.toString().trim()
        if line and line?
          timestamp = Date.now()
          defaultLifeD = Settings.findOne({'name':'unknown'}).life
          defaultLife = getDestroyAtMillis(defaultLifeD)
          # get systemID from line and find a setting
          if rgxSystem.test(line) is true 
            rawSysId = line.match(rgxSystem)[0]
            sysId = rawSysId.trim().toString().slice(0,-1)
            setting = Settings.findOne({name: sysId})
          
            # get regex patterns from setting doc
            if setting and setting? 
            
              # test & parse rgx date
              if setting.regex_date and setting.regex_date?
                rgx_date = new RegExp(setting.regex_date.toString())
                if rgx_date.test(line) is true
                  lineDatestamp = line.match(rgx_date)[0].trim().toString()
                  lineMillis = new Date(lineDatestamp).getTime()
            
              # test & parse rgx content
              if setting and setting? and setting.regex_content and setting.regex_content?
                rgx_content = new RegExp(setting.regex_content.toString())
                if rgx_content.test(line) is true
                  lineContent = line.match(rgx_content)[0].trim().toString()  

              # test & parse rgx log lvl
              if setting and setting? and setting.regex_lvl and setting.regex_lvl?
                rgx_lvl = new RegExp(setting.regex_lvl.toString())
                if rgx_lvl.test(line) is true
                  lineLvl = line.match(rgx_lvl)[0].trim().toString()
                
              # what is the lifetime of this post ?
              if setting and setting? and setting.life and setting.life?
                destroyAt = getDestroyAtMillis(setting.life)
              # all patterns got parsed ?
              if lineMillis and lineMillis? and sysId and sysId? and lineContent and lineContent? and lineLvl and lineLvl? and destroyAt and destroyAt?
                Logs.insert({'rawLine':line, 'incomeMillis':timestamp, 'parsed': {'lineMillis':lineMillis, 'system':sysId, 'content':lineContent, 'lvl':lineLvl, 'destroyAt':destroyAt}})
              else
                if lineMillis and lineMillis? and sysId and sysId? and lineContent and lineContent? and destroyAt and destroyAt?
                  Logs.insert({'rawLine':line, 'incomeMillis':timestamp, 'parsed': {'lineMillis':lineMillis, 'system':sysId, 'content':lineContent, 'destroyAt':destroyAt}})
                else
                  if sysId and sysId? and lineContent and lineContent? and destroyAt and destroyAt?
                    Logs.insert({'rawLine':line, 'incomeMillis':timestamp, 'parsed': {'system':sysId, 'content':lineContent, 'destroyAt':destroyAt}})
                  else
                    if sysId and sysId? and destroyAt and destroyAt?
                      Logs.insert({'rawLine':line, 'incomeMillis':timestamp, 'parsed': {'system':sysId, 'destroyAt':destroyAt}})
                    else
                      Logs.insert({'rawLine':line, 'incomeMillis':timestamp})
            else
              # no setting found for this system
              Logs.insert({'rawLine':line, 'incomeMillis':timestamp,'parsed':{'destroyAt':defaultLife, 'system':'unknown'}})
          else
            # no system id found in line ...
            Logs.insert({'rawLine':line, 'incomeMillis':timestamp, 'parsed':{'destroyAt':defaultLife, 'system':'unknown'}})
        else
          # console.log "empty line..."
          undefined
      .run()

    sock.on 'close', (data)->
      console.log 'CLOSED DOWN'

  .listen(PORT, HOST)
  console.log 'TCP Server running'