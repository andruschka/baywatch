# TEMPLATE EVENTS
Template.home.events  
  'click .line' : (e)->
    e.preventDefault()
    $("#line-#{this._id}").toggleClass('nowrap-line')

  'click .system' : (e)->
    sTxt = $('#search').val()
    sys = $(e.currentTarget).text().trim()
    if sTxt and sTxt?
      newTxt = sTxt + ", " + sys
      Session.set('search_keywords', newTxt)
      $('#search').val(newTxt)
    else
      Session.set('search_keywords', sys)
      $('#search').val(sys)

  'click .lvl' : (e)->
    sTxt = $('#search').val()
    lvl = $(e.currentTarget).text().trim()
    if sTxt and sTxt?
      newTxt = sTxt + ", " + lvl
      Session.set('search_keywords', newTxt)
      $('#search').val(newTxt)
    else
      Session.set('search_keywords', lvl)
      $('#search').val(lvl)

Template.navbar.events
  'keyup [name=search]': (e,context)->
    searchString = e.currentTarget.value.toString().trim()
    Session.set('search_keywords', searchString)
  'click #showAll' : (e)->
    e.preventDefault()
    Session.set 'limit', 1000000000
  'click #showSettings' : (e)->
    e.preventDefault()
    $('#settings-panel').fadeIn()
    $('#darken').fadeIn()

Template.helper.events
  'click .close-panels' : (e)->
    e.preventDefault()
    $('.modal').fadeOut()
    $('#darken').fadeOut()
    closeModal()
    resetSettingPanel()

  'click #addSetting' : (e)->
    e.preventDefault()
    $('#settings-panel').fadeOut()
    $('#new-setting-panel').fadeIn()

  'click #createNewSetting' : (e)->
    e.preventDefault()
    name = $('#set-name').val().toString().trim()
    life = $('#set-life').val()
    rgx_date = $('#set-rgx-date').val().toString().trim()
    rgx_lvl = $('#set-rgx-lvl').val().toString().trim()
    rgx_notification = $('#set-rgx-notification').val().toString().trim()
    emlArr = $('#set-email-to').val().toString().trim().split(' ')
    emlArr = _.compact emlArr
    rgx_content = $('#set-rgx-content').val().toString().trim()    
    if name and name?
      unless Settings.findOne({name: name})?
        hash = {}
        hash.name = name
        hash.life = life
        if rgx_date and rgx_date?
          hash.regex_date = rgx_date
        else
          hash.regex_date = ""
        if rgx_content and rgx_content?
          hash.regex_content = rgx_content
        else
          hash.regex_content = ""
        if rgx_lvl and rgx_lvl?
          hash.regex_lvl = rgx_lvl
        else
          hash.regex_lvl = ""
        if rgx_notification and rgx_notification?
          if emlArr and emlArr.length > 0
            hash.regex_notification = rgx_notification
            hash.email_to = emlArr
          else
            alert "You must enter at least one email!"
            undefined
        else
          hash.regex_notification = ""  
          hash.email_to = []
        console.log hash
        Settings.insert(hash)
        # setting panel to default
        closeModal()
        resetSettingPanel()
      else
        alert "There is already a setting for this name / tag"
    else
      alert "You have to specify a name."

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

  # EDIT setting stuff
  'click .edit-setting-btn' : (e)->
    e.preventDefault()
    self = this
    toggleEditSetting(self)
  'click .save-edit-btn' : (e)->
    e.preventDefault()
    self = this
    newLife = $("#new-life-#{self._id}").val()
    newRgxDate = $("#edit-rgx-date-#{self._id}").val().toString().trim()
    newRgxLvl = $("#edit-rgx-lvl-#{self._id}").val().toString().trim()
    newRgxNoti = $("#edit-rgx-notification-#{self._id}").val().toString().trim()
    emlArr = $("#edit-email-to-#{self._id}").val().toString().trim().split(' ')
    emlArr = _.compact emlArr
    newRgxCon = $("#edit-rgx-content-#{self._id}").val().toString().trim()
    Settings.update({'_id':self._id}, {$set: {life:newLife, regex_date:newRgxDate, regex_lvl:newRgxLvl, regex_notification:newRgxNoti, regex_content:newRgxCon, email_to:emlArr}})
  'click .cancel-edit-btn' : (e)->
    e.preventDefault()
    self = this
    # panel back to default
    toggleEditSetting(self)

# Helping functions
closeModal = ()->
  $('.modal').fadeOut()
  $('#darken').fadeOut()
resetSettingPanel = ()->
  # hide edit container
  $('.edit-setting-container').hide()
  # reset new setting fields
  $('#new-setting-panel').fadeOut()
  $('#set-name').val("")
  $("#set-life option[value=-1]").attr("selected", "selected")
  $('#set-rgx-date').val("")
  $('#set-rgx-lvl').val("")
  $('#set-rgx-content').val("")
toggleEditSetting = (self)->
  inpLife = $("#edit-life-#{self._id}")
  inpDate = $("#edit-rgx-date-#{self._id}")
  inpLvl = $("#edit-rgx-lvl-#{self._id}")
  inpNoti = $("#edit-rgx-notification-#{self._id}")
  inpEmls = $("#edit-email-to-#{self._id}")
  inpCon = $("#edit-rgx-content-#{self._id}")
  if inpLife.is ':visible'
    # turn in edit mode
    inpLife.hide()
    $("#new-life-#{self._id} option[value=#{self.life}]").attr("selected", "selected")
    $("#new-life-#{self._id}").show()
    inpDate.prop('disabled', false)
    inpLvl.prop('disabled', false)
    inpNoti.prop('disabled', false)
    inpEmls.prop('disabled', false)
    inpCon.prop('disabled', false)
    $("#save-this-#{self._id}").show()
    $("#edit-this-#{self._id}").hide()
    $("#cancel-this-#{self._id}").show()
    $("#delete-this-#{self._id}").hide()
  else
    # turn in show mode
    inpLife.show()
    $("#new-life-#{self._id}").hide()
    inpDate.prop('disabled', true)
    inpLvl.prop('disabled', true)
    inpNoti.prop('disabled', true)
    inpEmls.prop('disabled', true)
    inpCon.prop('disabled', true)
    $("#save-this-#{self._id}").hide()
    $("#edit-this-#{self._id}").show()
    $("#cancel-this-#{self._id}").hide()
    $("#delete-this-#{self._id}").show()
    inpDate.val("#{self.regex_date}")
    inpLvl.val("#{self.regex_lvl}")
    inpNoti.val("#{self.regex_notification}")
    inpEmls.val("#{self.email_to}")
    inpCon.val("#{self.regex_content}")