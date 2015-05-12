Meteor.startup ->
  if Meteor.isClient
    if Config.defaultLanguage
      TAPi18n.setLanguage Config.defaultLanguage
    else
      TAPi18n.setLanguage('en')
