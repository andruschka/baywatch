_smtp_ = Meteor.settings.smtp_settings
unless process.env.MAIL_URL?
  process.env.MAIL_URL = "smtp://#{_smtp_.user}:#{_smtp_.pass}@#{_smtp_.server}:#{_smtp_.port}/"

@sendMail = (reciArr,subject, text)->
  if reciArr?
    if reciArr.length is 1
      to = reciArr[0]
    else
      to = reciArr
    if to? and subject? and text?
      Email.send
        to: to
        from: "#{_smtp_.user}@#{_smtp_.server}"
        subject: "BAYWATCH Email Service --- #{subject}"
        text: text
