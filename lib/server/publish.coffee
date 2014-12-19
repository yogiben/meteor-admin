Meteor.publish 'adminCollection', (collection) ->
	check collection, String
	if Roles.userIsInRole this.userId, ['admin']
		adminCollectionObject(collection).find()
	else
		@ready()

Meteor.publish 'adminAuxCollections', (collection) ->
	check collection, String
	if Roles.userIsInRole @userId, ['admin']
		if typeof AdminConfig != 'undefined' and typeof AdminConfig.collections[collection].auxCollections == 'object'
			subscriptions = []
			_.each AdminConfig.collections[collection].auxCollections, (collection)->
				subscriptions.push adminCollectionObject(collection).find()
			subscriptions
		else
			@ready()
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