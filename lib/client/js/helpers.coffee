UI.registerHelper 'AdminConfig', ->
	AdminConfig if typeof AdminConfig != 'undefined'

UI.registerHelper 'admin_collections', ->
	if typeof AdminConfig != 'undefined'  and typeof AdminConfig.collections == 'object'
		_.map AdminConfig.collections, (obj, key)->
			obj = _.extend obj, {name:key}
			obj = _.defaults obj, {label: key,icon:'plus',color:'blue'}

UI.registerHelper 'admin_collection_name', ->
	Session.get 'admin_collection_name'

UI.registerHelper 'admin_current_id', ->
	Session.get 'admin_id'

UI.registerHelper 'admin_current_doc', ->
	Session.get 'admin_doc'


UI.registerHelper 'admin_fields', ->
	if not Session.equals('admin_collection','Users') and typeof AdminConfig != 'undefined' and typeof AdminConfig.collections[Session.get 'admin_collection'].fields == 'object'
		x = AdminConfig.collections[Session.get 'admin_collection'].fields
		console.log x
		x

UI.registerHelper 'admin_omit_fields', ->
	if typeof AdminConfig.autoForm != 'undefined' and typeof AdminConfig.autoForm.omitFields == 'object'
		global = AdminConfig.autoForm.omitFields
	if not Session.equals('admin_collection_name','Users') and typeof AdminConfig != 'undefined' and typeof AdminConfig.collections[Session.get 'admin_collection_name'].omitFields == 'object'
		collection = AdminConfig.collections[Session.get 'admin_collection_name'].omitFields
	if typeof global == 'object' and typeof collection == 'object'
		_.union global, collection
	else if typeof global == 'object'
		global
	else if typeof collection == 'object'
		collection

UI.registerHelper 'admin_table_columns', ->
	if typeof AdminConfig != 'undefined' and typeof AdminConfig.collections[Session.get 'admin_collection_name'] != 'undefined' and typeof AdminConfig.collections[Session.get 'admin_collection_name'].tableColumns == 'object'
		AdminConfig.collections[Session.get 'admin_collection_name'].tableColumns
	else
		[{label: 'ID';name:'_id'},{label:'Title';name:'title'}]

UI.registerHelper 'admin_table_value', (field,_id) ->
	if typeof field.collection == 'string' && typeof adminCollectionObject(Session.get 'admin_collection_name').findOne({_id:_id}) != 'undefined'
		aux_id = adminCollectionObject(Session.get 'admin_collection_name').findOne({_id:_id})[field.name]
		if field.collection == 'Users' and typeof Meteor.users.findOne({_id:aux_id}) != 'undefined'
			if typeof field.collection_property != 'undefined'
				aux_property = Meteor.users.findOne({_id:aux_id}).profile[field.collection_property]
			else
				aux_property = Meteor.users.findOne({_id:aux_id}).emails[0].address
			'<a class="btn btn-default btn-xs" href="/admin/' +  'users' + '/' + aux_id + '/edit">' + aux_property + '</a>'
		else if typeof field.collection_property == 'string' and typeof adminCollectionObject(field.collection).findOne({_id:aux_id}) != 'undefined'
			aux_property = adminCollectionObject(field.collection).findOne({_id:aux_id})[field.collection_property]
			'<a class="btn btn-default btn-xs" href="/admin/' +  field.collection + '/' + aux_id + '/edit">' + aux_property + '</a>'
	else if typeof adminCollectionObject(Session.get 'admin_collection_name') != 'undefined' and typeof adminCollectionObject(Session.get 'admin_collection_name').findOne({_id:_id}) != 'undefined'
		value = adminCollectionObject(Session.get 'admin_collection_name').findOne({_id:_id})[field.name]
		if typeof value == 'boolean' && value
			'<i class="fa fa-check"></i>'
		else
			value

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
		adminCollectionObject(collection).find().fetch().length

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
