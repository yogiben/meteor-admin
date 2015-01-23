Meteor.publish 'adminCollectionDoc', (collection, id) ->
	check collection, String
	check id, String
	if Roles.userIsInRole this.userId, ['admin']
		adminCollectionObject(collection).find(id)
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

Meteor.publish 'adminCollectionsCount', ->
	handles = []
	self = @

	_.each AdminTables, (table, name) ->
		id = new Mongo.ObjectID
		count = 0

		ready = false
		handles.push table.collection.find().observeChanges
			added: ->
				count += 1
				ready and self.changed 'adminCollectionsCount', id, {count: count}
			removed: ->
				count -= 1
				ready and self.changed 'adminCollectionsCount', id, {count: count}
		ready = true
		
		self.added 'adminCollectionsCount', id, {collection: name, count: count}

	self.onStop ->
		_.each handles, (handle) -> handle.stop()
	self.ready()

Meteor.publish null, ->
	Meteor.roles.find({})