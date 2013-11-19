Logs = new Meteor.Collection 'logs'
Settings = new Meteor.Collection 'settings'

Meteor.subscribe 'all_logs'
Meteor.subscribe 'all_settings'
Session.setDefault 'editSet', ''

Template.home.logs = ()->
  return Logs.find({},{sort: {timestamp: -1}})

Template.home.getDate = (mills)->
  date = new Date(mills)
  return date.toString()

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
  'click #searchGo' : (e)->
    e.preventDefault()
    tag = $('#search').val().trim()
    if tag? and tag isnt ""
      $('#search').val("")
      console.log tag
      result = Logs.find({}, {logs: tag})
    else
      alert "No empty search"
  'click #settingsGo' : (e)->
    e.preventDefault()
    $('#settings-panel').fadeIn()
    $('#darken').fadeIn()
  'click #add-setting' : (e)->
    e.preventDefault()
    $('#new-setting-panel').fadeIn()
    $('#darken').fadeIn()

Template.helper.events
  'click .close-panels' : (e)->
    e.preventDefault()
    $('.modal').fadeOut()
    $('#darken').fadeOut()
  
  'click #add-setting' : (e)->
    e.preventDefault()
    name = $('#set-name').val().trim()
    life = $('#set-life').val()
    rgx_date = $('#set-rgx-date').val().trim().toString()
    rgx_content = $('#set-rgx-content').val().trim().toString()
    
    if name? and name
      if rgx_date? and rgx_date
        if rgx_content? and rgx_content
          Settings.insert({name: name, life: life, regex_date: rgx_date, regex_content: rgx_content})
          # setting panel to default
          $('#new-setting-panel').fadeOut()
          $('#darken').fadeOut()
          $('#set-name').val("")
          $("#set-life option[value=-1]").attr("selected", "selected")
          $('#set-rgx-date').val("")
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
        $('#set-rgx-content').val("")
    else
      alert "You have to specify a name."

    console.log name
    console.log life
    console.log rgx_date
    console.log rgx_content
  
  'click .edit-setting-btn' : (e)->
    e.preventDefault()
    self = this
    console.log self

  'click .delete-setting-btn' : (e)->
    e.preventDefault()
    self = this
    if confirm 'Are you sure that you want to delete this setting?'
      Settings.remove({_id: self._id})
  
  'click .save-edit' : (e)->
    e.preventDefault()
    self = this
    edPanel = '#edit-rgx-date-' + self._id
    ecPanel = '#edit-rgx-content-' + self._id
    edited_date = $(edPanel).val().trim().toString()
    edited_content = $(ecPanel).val().trim().toString()
    console.log edited_date
    console.log edited_content

