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

Template.home.getLvlClass = (lvl)->
  if lvl.trim() is "INFO"
    result = "lvlInfo"
  else
    if lvl.trim() is "WARNING"
      result = "lvlWarning"
    else
      if lvl.trim() is "ERROR"
        result = "lvlError"
      else
        if lvl.trim() is 'info'
          result = "lvlInfo"
        else
          if lvl.trim() is 'warning'
            result = 'lvlWarning'
          else
            if lvl.trim() is 'error'
              result = 'lvlError'
            else
              result = "lvlNA"
  return result

Template.helper.settings = ()->
  return Settings.find()
  
Template.helper.which_span = (life)->
  if life is "1"
    span = "1 day"
  else
    if life is "7"
      span = "1 week"
    else
      if life is "31"
        span = "1 month"
      else if life is "365"
        span = "1 year"
      else
        span = "permanent"
  return span

# mongo debug helper
Template.home.events
  'click .line' : (e)->
    e.preventDefault()
    $("#line-#{this._id}").toggleClass('nowrap-line')

  'click .system' : (e)->
    sys = $(e.currentTarget).text().trim()
    sys = sys.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, "\\$&")
    Session.set('search_keywords', sys)
    $('#search').val(sys)

Template.navbar.events
  'keyup [name=search]': (e,context)->
    Session.set('search_keywords', e.currentTarget.value.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, "\\$&"))

  'click #showSettings' : (e)->
    e.preventDefault()
    $('#settings-panel').fadeIn()
    $('#darken').fadeIn()

Template.helper.events
  'click .close-panels' : (e)->
    e.preventDefault()
    $('.modal').fadeOut()
    $('#darken').fadeOut()
    $('.edit-setting-container').hide()
  
  'click #addSetting' : (e)->
    e.preventDefault()
    $('#settings-panel').fadeOut()
    $('#new-setting-panel').fadeIn()
  
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
    if editItem.is(':visible')
      editItem.fadeOut()
    else
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
    
    inpLife = $("#edit-life-#{self._id}")
    inpDate = $("#edit-rgx-date-#{self._id}")
    inpLvl = $("#edit-rgx-lvl-#{self._id}")
    inpCon = $("#edit-rgx-content-#{self._id}")
    
    inpLife.hide()
    $("#new-life-#{self._id} option[value=#{self.life}]").attr("selected", "selected")
    $("#new-life-#{self._id}").show()
    inpDate.prop('disabled', false)
    inpLvl.prop('disabled', false)
    inpCon.prop('disabled', false)
    $("#save-this-#{self._id}").show()
    $("#edit-this-#{self._id}").hide()
    $("#cancel-this-#{self._id}").show()
    $("#delete-this-#{self._id}").hide()
    
  'click .save-edit-btn' : (e)->
    e.preventDefault()
    self = this

    newLife = $("#new-life-#{self._id}").val()
    newRgxDate = $("#edit-rgx-date-#{self._id}").val().toString().trim()
    newRgxLvl = $("#edit-rgx-lvl-#{self._id}").val().toString().trim()
    newRgxCon = $("#edit-rgx-content-#{self._id}").val().toString().trim()
    
    if self.life is newLife and self.regex_date is newRgxDate and self.regex_lvl is newRgxLvl and self.regex_content is newRgxCon
      console.log "no new stuff here"

      # panel back to default
      inpLife = $("#edit-life-#{self._id}")
      inpDate = $("#edit-rgx-date-#{self._id}")
      inpLvl = $("#edit-rgx-lvl-#{self._id}")
      inpCon = $("#edit-rgx-content-#{self._id}")

      inpLife.show()
      $("#new-life-#{self._id}").hide()
      inpDate.prop('disabled', true)
      inpLvl.prop('disabled', true)
      inpCon.prop('disabled', true)
      $("#save-this-#{self._id}").hide()
      $("#edit-this-#{self._id}").show()
      $("#cancel-this-#{self._id}").hide()
      $("#delete-this-#{self._id}").show()
      
    else
      Settings.update({'_id':self._id}, {$set: {life:newLife, regex_date:newRgxDate, regex_lvl:newRgxLvl, regex_content:newRgxCon}})
      
  'click .cancel-edit-btn' : (e)->
    e.preventDefault()
    self = this
    
    # panel back to default
    inpLife = $("#edit-life-#{self._id}")
    inpDate = $("#edit-rgx-date-#{self._id}")
    inpLvl = $("#edit-rgx-lvl-#{self._id}")
    inpCon = $("#edit-rgx-content-#{self._id}")

    inpLife.show()
    $("#new-life-#{self._id}").hide()
    inpDate.prop('disabled', true)
    inpLvl.prop('disabled', true)
    inpCon.prop('disabled', true)
    $("#save-this-#{self._id}").hide()
    $("#edit-this-#{self._id}").show()
    $("#cancel-this-#{self._id}").hide()
    $("#delete-this-#{self._id}").show()
    
    inpDate.val("#{self.regex_date}")
    inpLvl.val("#{self.regex_lvl}")
    inpCon.val("#{self.regex_content}")