Fiber = Meteor.require 'fibers'
net = Meteor.require 'net'
carrier = Meteor.require 'carrier'

HOST = '127.0.0.1'
PORT = '6969'

net.createServer (sock)->
  console.log 'SERVER CONNECTED TO : ' + sock.remoteAddress + ':'+ sock.remotePort
  carrier.carry sock, (line)->
    console.log 'got one line: ' + line

    Fiber ()->

      timestamp = Date.now()
      # get systemID from line and find in Settings
      rgxSysId = line.match(/\s[A-Za-z]*:\s/)[0]
      sysId = rgxSysId.trim().toString().slice(0,-1)
      setting = Settings.findOne({name: sysId})

      # parse line with regex config from Settings
      if setting and setting? and setting.regex_date and setting.regex_date?
        rgx_date = new RegExp(setting.regex_date.toString())
        rgx_content = new RegExp(setting.regex_content.toString())
        if rgx_date.test(line) is true
          if rgx_content.test(line)
            lineDatestamp = line.match(rgx_date)[0].trim().toString()
            lineContent = line.match(rgx_content)[0].trim().toString()
            lineDateObj = new Date(lineDatestamp).toDateString()
            lineTimeObj = new Date(lineDatestamp).toTimeString()
        # insert raw line and millisec + parsed date / time / system / content
        Logs.insert({'rawLine':line, 'incomeMills':timestamp, 'parsed': {'date':lineDateObj, 'time':lineTimeObj, 'system':sysId, 'content':lineContent}})
      else
        console.log "there is no regex setting..." 
        # insert raw line and millisec
        Logs.insert({'rawLine':line, 'incomeMills':timestamp})

    .run()

  sock.on 'close', (data)->
    console.log 'CLOSED DOWN'

.listen(PORT, HOST)
console.log 'TCP Server listening on ' + HOST + ':' + PORT