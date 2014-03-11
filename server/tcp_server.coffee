Fiber = Meteor.require 'fibers'
net = Meteor.require 'net'
carrier = Meteor.require 'carrier'

HOST = Meteor.settings.HOST
PORT = Meteor.settings.PORT

rgxSystem = new RegExp(/\s[A-Za-z]*:\s/)

net.createServer (sock)->
  console.log 'SERVER CONNECTED TO : ' + sock.remoteAddress + ':'+ sock.remotePort

  carrier.carry sock, (line)->
    Fiber ()->
      line = line.toString().trim()
      if line and line?
        console.log "got a log line: " + line
        timestamp = Date.now()
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
              if setting.life is "1"
                destroyAt = timestamp + 86400000
              else
                if setting.life is "7"
                  destroyAt = timestamp + 604800000
                else
                  if setting.life is "31"
                    destroyAt = timestamp + 2678400000
                  else
                    if setting.life is "365"
                      destroyAt = timestamp + 31536000000
                    else
                      destroyAt = timestamp + 31536000000000
            
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
            Logs.insert({'rawLine':line, 'incomeMillis':timestamp})
        else
          # no system id found in line ...
          Logs.insert({'rawLine':line, 'incomeMillis':timestamp})
      else
        console.log "empty line..."
    .run()

  sock.on 'close', (data)->
    console.log 'CLOSED DOWN'

.listen(PORT, HOST)
console.log 'TCP Server running, listening on ' + HOST + ':' + PORT

# ##########################################################
# Developing a new version for tcp log-fisher              #
# ##########################################################
# Fiber = Meteor.require 'fibers'
# net = Meteor.require 'net'
# carrier = Meteor.require 'carrier'
# 
# if Meteor.settings.HOST and Meteor.settings.HOST? and Meteor.settings.PORT and Meteor.settings.PORT?
#   HOST = Meteor.settings.HOST
#   PORT = Meteor.settings.PORT
# 
#   rgxSystem = new RegExp(/###[A-Za-z]*###/)
# 
#   net.createServer {allowHalfOpen: true}, (sock)->
#     console.log '['+new Date+'] BAYWATCH CONNECTED TO ' + sock.remoteAddress + ':'+ sock.remotePort
# 
#     carrier.carry sock, (line)->
#       Fiber ()->
#         line = line.toString().trim()
#         console.log line
#         console.log line
#         if line and line?
#           timestamp = Date.now()
#           # get systemID from line and find a setting
#           if rgxSystem.test(line) is true 
#             console.log 'fetched line from known fisher-system'
#             rawSysId = line.match(rgxSystem)[0]
#             sysId = rawSysId.replace /###/g, ''
#             console.log sysId
#             line = line.split('###'+sysId+'###')[1].trim()
# 
#             setting = Settings.findOne({name: sysId})
#           
#             # get regex patterns from setting doc
#             if setting and setting? 
#               console.log 'setting found'
#               # test & parse rgx date
#               if setting.regex_date and setting.regex_date?
#                 rgx_date = new RegExp(setting.regex_date.toString())
#                 if rgx_date.test(line) is true
#                   lineDatestamp = line.match(rgx_date)[0].trim().toString()
#                   lineMillis = new Date(lineDatestamp).getTime()
#             
#               # test & parse rgx content
#               if setting and setting? and setting.regex_content and setting.regex_content?
#                 rgx_content = new RegExp(setting.regex_content.toString())
#                 if rgx_content.test(line) is true
#                   lineContent = line.match(rgx_content)[0].trim().toString()  
# 
#               # test & parse rgx log lvl
#               if setting and setting? and setting.regex_lvl and setting.regex_lvl?
#                 rgx_lvl = new RegExp(setting.regex_lvl.toString())
#                 if rgx_lvl.test(line) is true
#                   lineLvl = line.match(rgx_lvl)[0].trim().toString()
#                 
#               # what is the lifetime of this post ?
#               if setting and setting? and setting.life and setting.life?
#                 if setting.life is "1"
#                   destroyAt = timestamp + 86400000
#                 else
#                   if setting.life is "7"
#                     destroyAt = timestamp + 604800000
#                   else
#                     if setting.life is "31"
#                       destroyAt = timestamp + 2678400000
#                     else
#                       if setting.life is "365"
#                         destroyAt = timestamp + 31536000000
#                       else
#                         destroyAt = timestamp + 31536000000000
#             
#               # all patterns got parsed ?
#               if lineMillis and lineMillis? and sysId and sysId? and lineContent and lineContent? and lineLvl and lineLvl? and destroyAt and destroyAt?
#                 Logs.insert({'rawLine':line, 'incomeMillis':timestamp, 'parsed': {'lineMillis':lineMillis, 'system':sysId, 'content':lineContent, 'lvl':lineLvl, 'destroyAt':destroyAt}})
#               else
#                 if lineMillis and lineMillis? and sysId and sysId? and lineContent and lineContent? and destroyAt and destroyAt?
#                   Logs.insert({'rawLine':line, 'incomeMillis':timestamp, 'parsed': {'lineMillis':lineMillis, 'system':sysId, 'content':lineContent, 'destroyAt':destroyAt}})
#                 else
#                   if sysId and sysId? and lineContent and lineContent? and destroyAt and destroyAt?
#                     Logs.insert({'rawLine':line, 'incomeMillis':timestamp, 'parsed': {'system':sysId, 'content':lineContent, 'destroyAt':destroyAt}})
#                   else
#                     if sysId and sysId? and destroyAt and destroyAt?
#                       Logs.insert({'rawLine':line, 'incomeMillis':timestamp, 'parsed': {'system':sysId, 'destroyAt':destroyAt}})
#                     else
#                       Logs.insert({'rawLine':line, 'incomeMillis':timestamp})
#             else
#               console.log 'no setting'
#               # no setting found for this system
#               Logs.insert({'rawLine':line, 'incomeMillis':timestamp})
#           else
#             # no system id found in line ...
#             Logs.insert({'rawLine':line, 'incomeMillis':timestamp})
#         else
#           console.log "empty line..."
#       .run()
# 
#     sock.on 'close', (data)->
#       console.log 'CLOSED DOWN'
# 
#   .listen(PORT, HOST)
#   console.log 'BAYWATCH listening on ' + HOST + ':' + PORT
#   
# else
#   console.log "PLEASE START BAYWATCH WITH THE STARTUP SCRIPT"