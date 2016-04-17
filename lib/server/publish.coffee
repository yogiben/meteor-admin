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
	self = @

	collectionsWithoutCustomCounter = _.reduce AdminConfig?.collections, (result, collection, name) ->
		result[name] = collection if not collection.countSubscription and not collection.count
		result
	, {}

	collectionsWithCountFn = _.reduce AdminConfig?.collections, (result, collection, name) ->
		result[name] = collection if collection.count
		result
	, {}

	_.each collectionsWithoutCustomCounter, (collection, name) ->
		id = new Mongo.ObjectID
		count = 1
		table = AdminTables[name]
		ready = false
		selector = if table.selector then table.selector(self.userId) else {}
		handles.push table.collection.find(selector).observeChanges
			added: ->
				count += 1
				ready and self.changed 'adminCollectionsCount', id, {count: count}
			removed: ->
				count -= 1
				ready and self.changed 'adminCollectionsCount', id, {count: count}
		ready = true

		self.added 'adminCollectionsCount', id, {collection: name, count: count}

	_.each collectionsWithCountFn, (collection, name) ->
		id = new Mongo.ObjectID
		count = collection.count()
		self.added 'adminCollectionsCount', id, {collection: name, count: count}

	self.onStop ->
		_.each handles, (handle) -> handle.stop()
	self.ready()

Meteor.publish null, ->
	Meteor.roles.find({})
