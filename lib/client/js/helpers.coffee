Template.registerHelper('AdminTables', AdminTables);

UI.registerHelper 'AdminConfig', ->
	AdminConfig if typeof AdminConfig != 'undefined'

UI.registerHelper 'admin_collections', ->
	collections = {}
	if typeof AdminConfig != 'undefined'  and typeof AdminConfig.collections == 'object'
		collections = AdminConfig.collections
	collections.Users =
		collectionObject: Meteor.users
		icon: 'user'

	_.map collections, (obj, key) ->
		obj = _.extend obj, {name:key}
		obj = _.defaults obj, {label: key,icon:'plus',color:'blue'}

UI.registerHelper 'admin_collection_name', ->
	Session.get 'admin_collection_name'

UI.registerHelper 'admin_current_id', ->
	Session.get 'admin_id'

UI.registerHelper 'admin_current_doc', ->
	Session.get 'admin_doc'

UI.registerHelper 'admin_is_users_collection', ->
	Session.get('admin_collection_name') == 'Users'

UI.registerHelper 'admin_sidebar_items', ->
	AdminDashboard.sidebarItems

UI.registerHelper 'admin_collection_items', ->
	items = []
	_.each AdminDashboard.collectionItems, (fn) =>
		item = fn @name, '/admin/' + @name
		if item?.title and item?.url
			items.push item
	items

UI.registerHelper 'AdminSchemas', ->
	AdminDashboard.schemas

UI.registerHelper 'adminGetSkin', ->
	if typeof AdminConfig.dashboard != 'undefined' and typeof AdminConfig.dashboard.skin == 'string'
		AdminConfig.dashboard.skin
	else
		'blue'

UI.registerHelper 'adminIsUserInRole', (_id,role)->
	Roles.userIsInRole _id, role

UI.registerHelper 'adminGetUsers', ->
	Meteor.users

UI.registerHelper 'adminUserSchemaExists', ->
	typeof Meteor.users._c2 == 'object'

UI.registerHelper 'adminCollectionLabel', (collection)->
	AdminDashboard.collectionLabel(collection) if collection?

UI.registerHelper 'adminCollectionCount', (collection)->
	if collection == 'Users'
		Meteor.users.find().fetch().length
	else
		AdminCollectionsCount.findOne({collection: collection})?.count

UI.registerHelper 'adminTemplate', (collection,mode)->
	if collection.toLowerCase() != 'users' && typeof AdminConfig.collections[collection].templates != 'undefined'
		AdminConfig.collections[collection].templates[mode]

UI.registerHelper 'adminGetCollection', (collection)->
	AdminConfig.collections[collection]

UI.registerHelper 'adminWidgets', ->
	if typeof AdminConfig.dashboard != 'undefined' and typeof AdminConfig.dashboard.widgets != 'undefined'
		AdminConfig.dashboard.widgets
		
UI.registerHelper 'adminUserEmail', (user) ->
	if user && user.emails && user.emails[0] && user.emails[0].address
		user.emails[0].address
	else if user && user.services && user.services.facebook && user.services.facebook.email
		user.services.facebook.email
	else if user && user.services && user.services.google && user.services.google.email
		user.services.google.email
