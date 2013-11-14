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
      if setting and setting? and setting.rgx and setting.rgx?
        # parse line with regex config
        rgxStr = setting.rgx.toString()
        rgxSet = rgxStr.split('###')
        lineSts = []
        for rgx in rgxSet
          newRgx = new RegExp(rgx)
          if newRgx.test(line) is true
            resArr = line.match(newRgx)
            lineSts.push resArr[0]
        lineDate = lineSts[0].trim()
        lineTime = lineSts[1].trim()
        lineSys = lineSts[2].trim()
        lineCont = lineSts[3].trim()
        # Logs.insert({'log':line, 'timestamp':timestamp, '@date':lineDate, '@time':lineTime, '@system':lineSys, '@content':lineCont})
        dateObj = new Date(lineDate + "T" + lineTime + "Z")
        console.log dateObj
      else
        console.log "there is no regex setting..." 
        Logs.insert({'log':line, 'timestamp':timestamp})
    .run()

  sock.on 'close', (data)->
    console.log 'CLOSED DOWN'

.listen(PORT, HOST)
console.log 'TCP Server listening on ' + HOST + ':' + PORT