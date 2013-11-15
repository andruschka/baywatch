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
      # get system identifier from line
      rgxSysId = line.match(/\s[A-Za-z]*:\s/)[0]
      sysId = rgxSysId.trim().toString().slice(0,-1)
      console.log sysId
      # read Setting by identifier
      setting = Settings.findOne({name: sysId})
      # console.log setting
      if setting and setting? and setting.regex_date and setting.regex_date?
        # parse line with regex config
        rgx_date = new RegExp(setting.regex_date.toString())
        rgx_content = new RegExp(setting.regex_content.toString())
        if rgx_date.test(line) is true
          if rgx_content.test(line)
            lineDate = line.match(rgx_date)
            lineContent = line.match(rgx_content)
            # console.log lineDate[0]
            # console.log lineContent[0]
            dateObj = new Date(lineDate[0])
            console.log dateObj
        # Logs.insert({'log':line, 'timestamp':timestamp, '@date':lineDate, '@time':lineTime, '@system':lineSys, '@content':lineCont})
      else
        console.log "there is no regex setting..." 
        Logs.insert({'log':line, 'timestamp':timestamp})
    .run()

  sock.on 'close', (data)->
    console.log 'CLOSED DOWN'

.listen(PORT, HOST)
console.log 'TCP Server listening on ' + HOST + ':' + PORT