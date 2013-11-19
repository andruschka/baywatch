Fiber = Meteor.require 'fibers'
net = Meteor.require 'net'
carrier = Meteor.require 'carrier'

HOST = '127.0.0.1'
PORT = '6969'

rgxSystem = new RegExp(/\s[A-Za-z]*:\s/)

net.createServer (sock)->
  console.log 'SERVER CONNECTED TO : ' + sock.remoteAddress + ':'+ sock.remotePort

  carrier.carry sock, (line)->
    console.log 'got one line: ' + line

    Fiber ()->
      timestamp = Date.now()

      # get systemID from line and find in Settings
      if rgxSystem.test(line) is true 
        rawSysId = line.match(rgxSystem)[0]
        sysId = rawSysId.trim().toString().slice(0,-1)
        setting = Settings.findOne({name: sysId})

      # parse line with regex config from Settings
      if setting and setting? and setting.regex_date and setting.regex_date?
        rgx_date = new RegExp(setting.regex_date.toString())
        rgx_content = new RegExp(setting.regex_content.toString())
        if rgx_date.test(line) is true
          if rgx_content.test(line)
            lineDatestamp = line.match(rgx_date)[0].trim().toString()
            lineMillis = new Date(lineDatestamp).getTime()
            lineContent = line.match(rgx_content)[0].trim().toString()
        # # DB insert raw line + incomme-millisec + parsed: date / time / system / content
        Logs.insert({'rawLine':line, 'incomeMillis':timestamp, 'parsed': {'lineMillis':lineMillis, 'system':sysId, 'content':lineContent}})
      else
        console.log "there is no regex setting..." 
        # # DB insert only raw line and incomme- millisec
        Logs.insert({'rawLine':line, 'incomeMillis':timestamp})

    .run()

  sock.on 'close', (data)->
    console.log 'CLOSED DOWN'

.listen(PORT, HOST)
console.log 'TCP Server listening on ' + HOST + ':' + PORT