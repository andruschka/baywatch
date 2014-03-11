_config_ = Meteor.settings

# ##################################################################################
# BAYWATCH API (beta) currently authorization only via predefined x-auth-token... #
# ##################################################################################

# ITS API TIME
Router.map ()->

  # POST logs to Baywatch
  this.route 'insertLog',
    where: 'server',
    path: '/api/logs/insert'
    action: ()->
      request = this.request
      response = this.response 
      token = request.headers['x-auth-token']
      timestamp = new Date().getTime()
      if token? and token is _config_.API_AUTH_TOKEN
        rawLine = request.body.line
        systemId = request.body.system
        if rawLine?
          line = rawLine
          if systemId?
            sysId = systemId
            setting = Settings.findOne({name: systemId})
            # get regex patterns from setting doc
            if setting and setting? 
              console.log 'setting found'
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
                console.log "testing log level"
                if rgx_lvl.test(line) is true
                  lineLvl = line.match(rgx_lvl)[0].trim().toString()
                  console.log "found log level: " + lineLvl 
                
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
            
            if line?
              newLogObj = {'rawLine':line, 'incomeMillis':timestamp, 'parsed': {}}
            if sysId?
              newLogObj.parsed.system = sysId
            if lineMillis?
              newLogObj.parsed.lineMillis = lineMillis
            if lineLvl?
              newLogObj.parsed.lvl = lineLvl
            if destroyAt?
              newLogObj.parsed.destroyAt = destroyAt
            newId = Logs.insert(newLogObj)
            # RESPONSE
            if newId?
              response.writeHead(201, {'Content-Type':'text/html'})
              response.end(newId)
          else
            newId = Logs.insert({'rawLine':rawLine, 'incomeMillis':timestamp})
            # RESPONSE
            response.writeHead(201, {'Content-Type':'text/html'});
            response.end(newId);
        else
          console.log 'received empty line'
      else
        response.writeHead(401, {'Content-Type':'text/html'});
        response.end('Invalid Auth key');

  # GET a log with id
  this.route 'getLog',
    where: 'server',
    path: '/api/log/:id'
    action: ()->
      request = this.request
      console.log request
      response = this.response 
      paramLogId = this.params.id
      token = request.headers['x-auth-token']
      timestamp = new Date().getTime()      
      if token? and token is _config_.API_AUTH_TOKEN
        result = Logs.findOne({'_id':paramLogId})
        response.writeHead(200, {'Content-Type':'application/json'});
        response.end(JSON.stringify(result));
      else
        response.writeHead(401, {'Content-Type':'text/html'});
        response.end('Invalid Auth key');