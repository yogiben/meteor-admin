Meteor.publishComposite 'adminCollectionDoc', (collection, id) ->
	check collection, String
	check id, Match.OneOf(String, Mongo.ObjectID)
	if Roles.userIsInRole this.userId, ['admin']
		find: ->
			adminCollectionObject(collection).find(id)
		children: AdminConfig?.collections?[collection]?.children or []
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
	hookHandles = []
	self = @

	_.each AdminTables, (table, name) ->
		id = new Mongo.ObjectID
		docCollection = adminCollectionObject(name)
		count = docCollection.find().count()
		self.added 'adminCollectionsCount', id, {collection: name, count: count}

		update = -> self.changed 'adminCollectionsCount', id, {count: count}
		hookHandles.push docCollection.after.insert ->
			count++
			update()
		hookHandles.push docCollection.after.remove ->
			count--
			update()

	self.onStop ->
		_.each handles, (handle) -> handle.stop()
		_.each hookHandles, (handle) -> handle.remove()
	self.ready()

Meteor.publish null, ->
	Meteor.roles.find({})
