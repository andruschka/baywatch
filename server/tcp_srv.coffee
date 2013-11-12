# Fiber = Npm.require 'fibers'
# net = Npm.require 'net'
# carrier = Npm.require 'carrier'
# grok = Npm.require 'node-grok'
# 
# 
# # TCP SERVER LISTEN ON localhost:6969
# HOST = '127.0.0.1'
# PORT = '6969'
# 
# net.createServer (sock)->
#   console.log 'SERVER CONNECTED TO : ' + sock.remoteAddress + ':'+ sock.remotePort
#   carrier.carry sock, (line)->
#     console.log 'got one line: ' + line
#     Fiber ()->
#       timestamp = Date.now()
#       Logs.insert({'log':line, 'timestamp':timestamp})
#     .run()
#    
#   # # FUNCTION FOR WHOLE DATA STREAM
#   #  sock.on('data', function(data) {
#   #    console.log(data.toString())
#   #    Fiber(function() {
#   #      var timestamp = Date.now()
#   #      Logs.insert({'log':data, 'timestamp':timestamp})
#   #    }).run()
#   #  })
#   
#   sock.on 'close', (data)->
#     console.log 'CLOSED DOWN'
# 
# .listen(PORT, HOST)
# console.log 'TCP Server listening on ' + HOST + ':' + PORT