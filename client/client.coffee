Logs = new Meteor.Collection 'logs'
Settings = new Meteor.Collection 'settings'

Meteor.subscribe 'all_logs'
Meteor.subscribe 'all_settings'
Session.setDefault 'editSet', ''

Template.home.logs = ()->
  keywords = new RegExp(Session.get('search_keywords'), 'i')
  return Logs.find({rawLine:keywords},{sort: {incomeMillis: -1}})

Template.home.getDate = (mills)->
  date = new Date(mills)
  return date.toISOString()

Template.home.getFlagClass = (flag)->
  flag = flag.toString().trim()
  if flag is "INFO" or "info"
    result = "flagInfo"
  else
    if flag is "WARNING" or "warning"
      result = "flagWarning"
    else
      if flas is "ERROR" or "error"
        result = "flagError"
      else
        result = "flagNA"
  return result

Template.helper.settings = ()->
  return Settings.find()
  
Template.helper.which_span = (life)->
  if life is "1"
    span = "one day"
  else
    if life is "7"
      span = "one week"
    else
      if life is "31"
        span = "one month"
      else if life is "365"
        span = "one year"
      else
        span = "permanent"
  return span

# mongo debug helper
Template.home.events
  'click .line' : (e)->
    e.preventDefault()
    console.log this

Template.navbar.events
  'keyup [name=search]': (e,context)->
    Session.set('search_keywords', e.currentTarget.value.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, "\\$&"))
  'click #showSettings' : (e)->
    e.preventDefault()
    $('#settings-panel').fadeIn()
    $('#darken').fadeIn()
  'click #addSetting' : (e)->
    e.preventDefault()
    $('#new-setting-panel').fadeIn()
    $('#darken').fadeIn()

Template.helper.events
  'click .close-panels' : (e)->
    e.preventDefault()
    $('.modal').fadeOut()
    $('#darken').fadeOut()
    $('.edit-setting-container').hide()
    
  
  'click #addNewSetting' : (e)->
    e.preventDefault()
    name = $('#set-name').val().toString().trim()
    life = $('#set-life').val()
    rgx_date = $('#set-rgx-date').val().toString().trim()
    rgx_lvl = $('#set-rgx-lvl').val().toString().trim()
    rgx_content = $('#set-rgx-content').val().toString().trim()
    
    if name? and name
      if rgx_date? and rgx_date
        if rgx_content? and rgx_content
          Settings.insert({name: name, life: life, regex_date: rgx_date, regex_lvl: rgx_lvl, regex_content: rgx_content})
          # setting panel to default
          $('#new-setting-panel').fadeOut()
          $('#darken').fadeOut()
          $('#set-name').val("")
          $("#set-life option[value=-1]").attr("selected", "selected")
          $('#set-rgx-date').val("")
          $('#set-rgx-lvl').val("")
          $('#set-rgx-content').val("")
        else
          alert "You have to specify the RegExp for date AND content"
      else
        Settings.insert({name: name, life: life})
        # setting panel to default
        $('#new-setting-panel').fadeOut()
        $('#darken').fadeOut()
        $('#set-name').val("")
        $('#set-life option[value=-1]').attr("selected", "selected")
        $('#set-rgx-date').val("")
        $('#set-rgx-lvl').val("")
        $('#set-rgx-content').val("")
    else
      alert "You have to specify a name."
    console.log name
    console.log life
    console.log rgx_date
    console.log rgx_lvl
    console.log rgx_content
  
  'click .show-setting-btn' : (e)->
    e.preventDefault()
    self = this
    editItem = $(".edit-#{this._id}")
    $('.edit-setting-container').hide()
    editItem.fadeIn()

  'click .delete-setting-btn' : (e)->
    e.preventDefault()
    self = this
    if confirm 'Are you sure that you want to delete this setting?'
      Settings.remove({_id: self._id})

  'click .edit-setting-btn' : (e)->
    e.preventDefault()
    self = this
    
    $("#new-life-#{self._id} option[value=#{self.life}]").attr("selected", "selected")
    
    inpLife = $("#edit-life-#{self._id}")
    inpDate = $("#edit-rgx-date-#{self._id}")
    inpLvl = $("#edit-rgx-lvl-#{self._id}")
    inpCon = $("#edit-rgx-content-#{self._id}")

    inpLife.hide()
    $("#edit-this-#{self._id}").hide()

    $("#new-life-#{self._id}").fadeIn()
    $("#save-this-#{self._id}").fadeIn()
    inpDate.prop('disabled', false)
    inpLvl.prop('disabled', false)
    inpCon.prop('disabled', false)
    
    
  'click .save-edit-btn' : (e)->
    e.preventDefault()
    self = this

    newLife = $("#new-life-#{self._id}").val()
    newRgxDate = $("#edit-rgx-date-#{self._id}").val().toString().trim()
    newRgxLvl = $("#edit-rgx-lvl-#{self._id}").val().toString().trim()
    newRgxCon = $("#edit-rgx-content-#{self._id}").val().toString().trim()
    
    Settings.update({'_id':self._id}, {$set: {life:newLife, regex_date:newRgxDate, regex_lvl:newRgxLvl, regex_content:newRgxCon}})