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
    rgx_content = $('#set-rgx-content').val().toString().trim()    
    unless Settings.findOne({name: name})?
      if name and name?
        if rgx_date? and rgx_date
          if rgx_content? and rgx_content
            Settings.insert({name: name, life: life, regex_date: rgx_date, regex_lvl: rgx_lvl, regex_content: rgx_content})
            # setting panel to default
            closeModal()
            resetSettingPanel()
          else
            alert "You have to specify the RegExp for date AND content"
        else
          Settings.insert({name: name, life: life})
          # setting panel to default
          closeModal()
          resetSettingPanel()
      else
        alert "You have to specify a name."
    else
      alert "There is already a setting for this name / tag"
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