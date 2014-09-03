UI.registerHelper 'AdminConfig', ->
	AdminConfig if typeof AdminConfig != 'undefined'

UI.registerHelper 'admin_collections', ->
	if typeof AdminConfig != 'undefined'  and typeof AdminConfig.collections == 'object'
		_.map AdminConfig.collections, (obj, key)->
			obj = _.extend obj, {name:key}
			obj = _.defaults obj, {label: key,icon:'plus',color:'blue'}

UI.registerHelper 'admin_collection', ->
	Session.get 'admin_collection'

UI.registerHelper 'admin_current_id', ->
	Session.get 'admin_id'

UI.registerHelper 'admin_current_doc', ->
	Session.get 'admin_doc'

UI.registerHelper 'admin_omit_fields', ->
	if typeof AdminConfig.autoForm != 'undefined' and typeof AdminConfig.autoForm.omitFields == 'object'
		global = AdminConfig.autoForm.omitFields
	if typeof AdminConfig != 'undefined' and typeof AdminConfig.collections[Session.get 'admin_collection'].omitFields == 'object'
		collection = AdminConfig.collections[Session.get 'admin_collection'].omitFields
	if typeof global == 'object' and typeof collection == 'object'
		_.union global, collection
	else if typeof global == 'object'
		global
	else if typeof collection == 'object'
		collection

UI.registerHelper 'admin_table_columns', ->
	if typeof AdminConfig != 'undefined' and typeof AdminConfig.collections[Session.get 'admin_collection'] != 'undefined' and typeof AdminConfig.collections[Session.get 'admin_collection'].tableColumns == 'object'
		AdminConfig.collections[Session.get 'admin_collection'].tableColumns
	else
		[{label: 'ID';name:'_id'},{label:'Title';name:'title'}]

UI.registerHelper 'admin_table_value', (field,_id) ->
	if typeof field.collection == 'string' && typeof window[Session.get 'admin_collection'].findOne({_id:_id}) != 'undefined'
		aux_id = window[Session.get 'admin_collection'].findOne({_id:_id})[field.name]
		if field.collection == 'Users' and typeof Meteor.users.findOne({_id:aux_id}) != 'undefined'
			if typeof field.collection_property != 'undefined'
				aux_property = Meteor.users.findOne({_id:aux_id}).profile[field.collection_property]
			else
				aux_property = Meteor.users.findOne({_id:aux_id}).emails[0].address
			'<a class="btn btn-default btn-xs" href="/admin/' +  'users' + '/' + aux_id + '/edit">' + aux_property + '</a>'
		else if typeof field.collection_property == 'string' and typeof window[field.collection].findOne({_id:aux_id}) != 'undefined'
			aux_property = window[field.collection].findOne({_id:aux_id})[field.collection_property]
			'<a class="btn btn-default btn-xs" href="/admin/' +  field.collection + '/' + aux_id + '/edit">' + aux_property + '</a>'
	else if typeof window[Session.get 'admin_collection'] != 'undefined' and typeof window[Session.get 'admin_collection'].findOne({_id:_id}) != 'undefined'
		value = window[Session.get 'admin_collection'].findOne({_id:_id})[field.name]
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
		window[collection].find().fetch().length

UI.registerHelper 'adminTemplate', (collection,mode)->
	if collection.toLowerCase() != 'users' && typeof AdminConfig.collections[collection].templates != 'undefined'
		AdminConfig.collections[collection].templates[mode]

UI.registerHelper 'adminGetCollection', (collection)->
	AdminConfig.collections[collection]

UI.registerHelper 'adminWidgets', ->
	if typeof AdminConfig.dashboard != 'undefined' and typeof AdminConfig.dashboard.widgets != 'undefined'
		AdminConfig.dashboard.widgets
