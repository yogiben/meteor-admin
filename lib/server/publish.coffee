Meteor.publish 'adminCollection', (collection) ->
	if Roles.userIsInRole @userId, ['admin']
		global[collection].find()
	else
		@ready()

Meteor.publish 'adminAuxCollections', (collection) ->
	if Roles.userIsInRole @userId, ['admin']
		if typeof AdminConfig != 'undefined' and typeof AdminConfig.collections[collection].auxCollections == 'object'
			subscriptions = []
			_.each AdminConfig.collections[collection].auxCollections, (collection)->
				subscriptions.push global[collection].find()
			subscriptions
		else
			@ready()
	else
		@ready()

Meteor.publish 'adminAllCollections', ->
	if Roles.userIsInRole @userId, ['admin']
		if typeof AdminConfig != 'undefined'  and typeof AdminConfig.collections == 'object'
			subscriptions = []
			_.map AdminConfig.collections, (obj, key)->
				subscriptions.push global[key].find()
			subscriptions
	else
		@ready()

Meteor.publish 'adminUsers', ->
	if Roles.userIsInRole @userId, ['admin']
		Meteor.users.find()
	else
		@ready()

Meteor.publish 'adminUser', ->
	Meteor.users.find @userId

Meteor.publish null, ->
	Meteor.roles.find({})