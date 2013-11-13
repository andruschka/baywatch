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
      sysId = line.match(/\s[A-Za-z]*:\s/)[0]
      console.log sysId
      # read Setting by identifier
      # pipe line through grok config if there's one
      
      
      Logs.insert({'log':line, 'timestamp':timestamp})
    .run()
  
  sock.on 'close', (data)->
    console.log 'CLOSED DOWN'

.listen(PORT, HOST)
console.log 'TCP Server listening on ' + HOST + ':' + PORT