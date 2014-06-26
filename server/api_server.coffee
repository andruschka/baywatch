### 
BAYWATCH API (beta) currently authorization only via predefined x-auth-token...
### 
if Meteor.settings?
  _config_ = Meteor.settings.apiServer
if _config_.enabled? and _config_.enabled is true
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
            defaultLifeD = Settings.findOne({'name':'unknown'}).life
            defaultLife = getDestroyAtMillis(defaultLifeD)
            if systemId?
              sysId = systemId
              setting = Settings.findOne({name: systemId})
              # get regex patterns from setting doc
              if setting and setting? 
                # console.log 'setting found'
                # test & parse rgx date
                if setting.regex_date and setting.regex_date? and setting.regex_date isnt ''
                  rgx_date = new RegExp(setting.regex_date.toString())
                  if rgx_date.test(line) is true
                    lineDatestamp = line.match(rgx_date)[0].trim().toString()
                    lineMillis = new Date(lineDatestamp).getTime()
            
                # test & parse rgx content
                if setting and setting? and setting.regex_content and setting.regex_content? and setting.regex_content isnt ''
                  rgx_content = new RegExp(setting.regex_content.toString())
                  if rgx_content.test(line) is true
                    lineContent = line.match(rgx_content)[0].trim().toString()  

                # test & parse rgx log lvl
                if setting and setting? and setting.regex_lvl and setting.regex_lvl? and setting.regex_lvl isnt ''
                  rgx_lvl = new RegExp(setting.regex_lvl.toString())
                  # console.log "testing log level"
                  if rgx_lvl.test(line) is true
                    lineLvl = line.match(rgx_lvl)[0].trim().toString()
                    # console.log "found log level: " + lineLvl 
                
                # send Email if notification regex can parse
                if setting and setting? and setting.regex_notification? and setting.email_to? and setting.regex_notification isnt ''
                  rgx_notification = new RegExp(setting.regex_notification.toString())
                  if rgx_notification.test(line) is true
                    sendMail setting.email_to, "System: #{setting.name}", "Log notification got triggered by:\n #{line}"
                  undefined

                # what is the lifetime of this post ?
                if setting and setting? and setting.life and setting.life?
                  destroyAt = getDestroyAtMillis(setting.life)
            
              if line?
                newLogObj = {'rawLine':line, 'incomeMillis':timestamp, 'parsed': {}}
              if sysId?
                newLogObj.parsed.system = sysId
              else
                newLogObj.parsed.system = 'unknown'
              if lineMillis?
                newLogObj.parsed.lineMillis = lineMillis
              if lineContent?
                newLogObj.parsed.content = lineContent
              if lineLvl?
                newLogObj.parsed.lvl = lineLvl
              if destroyAt?
                newLogObj.parsed.destroyAt = destroyAt
              else
                newLogObj.parsed.destroyAt = defaultLife
              newId = Logs.insert(newLogObj)
              # RESPONSE
              if newId?
                response.writeHead(201, {'Content-Type':'text/html'})
                response.end(newId)
            else
              newId = Logs.insert({'rawLine':rawLine, 'incomeMillis':timestamp, 'parsed':{'destroyAt':defaultLife, 'system':'unknown'}})
              # RESPONSE
              response.writeHead(201, {'Content-Type':'text/html'});
              response.end(newId);
          else
            # console.log 'received empty line'
            undefined
        else
          response.writeHead(401, {'Content-Type':'text/html'});
          response.end('Invalid Auth key');

    # GET a log with id
    this.route 'getLog',
      where: 'server',
      path: '/api/log/:id'
      action: ()->
        request = this.request
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
  console.log 'API Server running'