Fiber = Meteor.require 'fibers'
net = Meteor.require 'net'
carrier = Meteor.require 'carrier'

HOST = '127.0.0.1'
PORT = '6969'

rgxSystem = new RegExp(/\s[A-Za-z]*:\s/)

net.createServer (sock)->
  console.log 'SERVER CONNECTED TO : ' + sock.remoteAddress + ':'+ sock.remotePort

  carrier.carry sock, (line)->
    Fiber ()->
      console.log 'got one line: ' + line
      
      timestamp = Date.now()

      # get systemID from line and find in Settings
      if rgxSystem.test(line) is true 
        rawSysId = line.match(rgxSystem)[0]
        sysId = rawSysId.trim().toString().slice(0,-1)
        setting = Settings.findOne({name: sysId})

        # parse line with regex config from Settings
        
        # check if setting exists for this system and if date & content & log lvl  - regex config exists 
        if setting and setting? and setting.regex_date and setting.regex_date?
          rgx_date = new RegExp(setting.regex_date.toString())
        if setting and setting? and setting.regex_content and setting.regex_content?
          rgx_content = new RegExp(setting.regex_content.toString())
        if setting and setting? and setting.regex_lvl and setting.regex_lvl?
          rgx_lvl = new RegExp(setting.regex_lvl.toString())
        
        console.log setting
        # # test rgx date
        # if rgx_date.test(line) is true
        #   lineDatestamp = line.match(rgx_date)[0].trim().toString()
        #   lineMillis = new Date(lineDatestamp).getTime()
        # # test rgx content
        # if rgx_content.test(line) is true
        #   lineContent = line.match(rgx_content)[0].trim().toString()  
        # # test rgx log lvl
        # if rgx_lvl.test(line) is true
        #   lineLvl = line.match(rgx_lvl)[0].trim().toString()
        # 
        # console.log sysId + " // " + lineMillis + " // " + lineLvl + " // " + lineContent
        # Logs.insert({'rawLine':line, 'incomeMillis':timestamp, 'parsed': {'lineMillis':lineMillis, 'system':sysId, 'content':lineContent}})
      else
        console.log "there is no regex setting... but inserting in DB" 
        Logs.insert({'rawLine':line, 'incomeMillis':timestamp})

    .run()

  sock.on 'close', (data)->
    console.log 'CLOSED DOWN'

.listen(PORT, HOST)
console.log 'TCP Server listening on ' + HOST + ':' + PORT