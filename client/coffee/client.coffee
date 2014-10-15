Session.setDefault('logCursor', 200)
Session.set('homeLoading', true)
Session.setDefault('lock', false)
Session.setDefault('search_keywords', '')
Session.setDefault('filter_systems', '')

@Logs = new Meteor.Collection 'logs'
@Settings = new Meteor.Collection 'settings'
Deps.autorun ->
  Meteor.subscribe 'all_logs', Session.get('logCursor'), Session.get('search_keywords'), Session.get('filter_systems'), ()->
    Session.set('homeLoading', false)
    Meteor.subscribe 'all_settings', ()->
      cntxt = $('#logChart').get(0).getContext('2d')
      data = dataFromLogs().dataStack
      new Chart(cntxt).Bar data

# # remote access to production server for testing ******************************
# remote = DDP.connect('http://show.logs.relax/')
# @Logs = new Meteor.Collection 'logs', remote
# @Settings = new Meteor.Collection 'settings', remote
# Deps.autorun ->
#   remote.subscribe 'all_logs', Session.get('logCursor'), Session.get('search_keywords'), Session.get('filter_systems'), ()->
#     Session.set('homeLoading', false)
#     remote.subscribe 'all_settings', ()->
#       cntxt = $('#logChart').get(0).getContext('2d')
#       data = dataFromLogs().dataStack
#       new Chart(cntxt).Bar data
#
# # ******************************************************************************

$(window).scroll ()->
  if $(window).scrollTop() >= $(document).height() - $(window).height() - 300
    # Session.set('homeLoading', true)
    Session.set('logCursor', Session.get('logCursor') + 30)
  if $('#table-legend')? and $('#table-legend').offset()?
    if $(window).scrollTop() >= $('#table-legend').offset().top + 100
      $('#table-legend').scrollToFixed
        marginTop: 51
        spacerClass: 'spacerheight'
        preFixed: ()->
          $('#table-legend').addClass('shadowed')
        preUnfixed: ()->
          $('#table-legend').removeClass('shadowed')
        



setNoti = (num)->
  if num > 1
    if navigator.userAgent.indexOf('Safari') != -1 and navigator.userAgent.indexOf('Chrome') == -1
      # its safari
    else
      Tinycon.setBubble(num)
    document.title = "Baywatch(" + num + ")"
  else
    document.title = "Baywatch"

Template.home.helpers
  logs : ()->
    return Logs.find({}, {sort:{incomeMillis: -1}})

  homeLoading : ()->
    return Session.get('homeLoading')

  getLvlClass : (lvl)->
    lvl = lvl.trim()
    isInfo = _.indexOf(lvlClassesInfo, lvl)
    isWarning = _.indexOf(lvlClassesWarning, lvl)
    isError = _.indexOf(lvlClassesError, lvl)
    if isInfo isnt -1
      result = "lvlInfo"
    else
      if isWarning isnt -1
        result = "lvlWarning"
      else
        if isError isnt -1
          result = "lvlError"
        else
          result = "lvlNA"
    return result

Template.settingsModal.helpers
  settings : ()->
    return Settings.find()
