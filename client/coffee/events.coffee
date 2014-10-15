# TEMPLATE EVENTS
Template.home.events
  'click .log-line' : (e)->
    e.preventDefault()
    console.log e.currentTarget
    $(e.currentTarget).toggleClass('nowrap-line')

  'click .system' : (e)->
    sTxt = $('#system-filter').val()
    sys = $(e.currentTarget).text().trim()
    if sTxt and sTxt?
      newTxt = sTxt + ", " + sys
      Session.set('filter_systems', newTxt)
      $('#system-filter').val(newTxt)
    else
      Session.set('filter_systems', sys)
      $('#system-filter').val(sys)

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
  'keyup #system-filter': (e,context)->
    searchString = e.currentTarget.value.toString().trim()
    Session.set('filter_systems', searchString)
  'keyup [name=search]': (e,context)->
    searchString = e.currentTarget.value.toString().trim()
    Session.set('search_keywords', searchString)
  'click #showAll' : (e)->
    e.preventDefault()
    Session.set 'logLimit', 1000000000
  'click #show-settings' : (e)->
    e.preventDefault()
    ms = $('#modal-space')
    settings = Blaze.renderWithData(Template.settingsModal , Settings.find(), ms.get(0))
    ms.modal('show')
    ms.on 'hidden.bs.modal', (e)->
      Blaze.remove(settings)
  'click #login': (e)->
      e.preventDefault()
      if Meteor.user() is null or Meteor.user() is undefined
        service = Accounts.loginServiceConfiguration.findOne({service: Meteor.settings.public.ownauth.serviceName})
        console.log service
        if service?
          Meteor.loginWithOwnauth {}, (error, result)->
            if error?
              console.log "Error on authentication: #{error}"
      else
        if confirm "Sie sind dabei sich auszuloggen"
          Meteor.logout()

Template.appLayout.events
  'click #addSetting' : (e)->
    e.preventDefault()
    ms = $('#modal-space')
    ms.modal('hide')
    Meteor.setTimeout ()->
      newSetting = Blaze.render(Template.newSettingModal, ms.get(0))
      ms.modal('show')
      ms.on 'hidden.bs.modal', (e)->
        Blaze.remove(newSetting)
    , 750
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
            return undefined
        else
          hash.regex_notification = ""
          hash.email_to = []
        console.log hash
        Settings.insert hash , ()->
          ms = $('#modal-space')
          ms.modal('hide')
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
    ms = $('#modal-space')
    ms.modal('hide')
    Meteor.setTimeout ()->
      edit = Blaze.renderWithData(Template.editSettingModal, self, ms.get(0))
      $("#set-life option[value=#{self.life}]").attr("selected", "selected")
      ms.modal('show')
      ms.on 'hidden.bs.modal', (e)->
        Blaze.remove(edit)
    , 750
  'click .save-changes' : (e)->
    e.preventDefault()
    self = this
    life = $('#set-life').val()
    rgx_date = $('#set-rgx-date').val().toString().trim()
    rgx_lvl = $('#set-rgx-lvl').val().toString().trim()
    rgx_notification = $('#set-rgx-notification').val().toString().trim()
    emlArr = $('#set-email-to').val().toString().trim().split(' ')
    emlArr = _.compact emlArr
    rgx_content = $('#set-rgx-content').val().toString().trim()
    hash = {}
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
        return undefined
    else
      hash.regex_notification = ""
      hash.email_to = []
    Settings.update {'_id':self._id}, {$set: {life:hash.life, regex_date:hash.regex_date, regex_lvl:hash.regex_lvl, regex_notification:hash.regex_notification, regex_content:hash.regex_content, email_to:hash.email_to}} , ()->
      ms = $('#modal-space')
      ms.modal('hide')
