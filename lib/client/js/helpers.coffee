# FIXME: this may affect user template
Template.adminPagesTable.replaces('_pagesTable')

UI.registerHelper 'AdminConfig', ->
	AdminConfig if typeof AdminConfig != 'undefined'

UI.registerHelper 'admin_collections', ->
	collections = {}
	if typeof AdminConfig != 'undefined'  and typeof AdminConfig.collections == 'object'
		collections = AdminConfig.collections
	collections.Users = AdminUsersCollection

	_.map collections, (obj, key) ->
		obj = _.extend obj, {name:key, routeName: adminCollectionRoute(key)}
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

UI.registerHelper 'admin_fields', ->
	if not Session.equals('admin_collection','Users') and typeof AdminConfig != 'undefined' and typeof AdminConfig.collections[Session.get 'admin_collection_name'].fields == 'object'
		x = AdminConfig.collections[Session.get 'admin_collection_name'].fields
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
		aux_id = lookup field.name, adminCollectionObject(Session.get 'admin_collection_name').findOne({_id:_id})
		if field.collection == 'Users' and typeof Meteor.users.findOne({_id:aux_id}) != 'undefined'
			if typeof field.collection_property != 'undefined'
				aux_property = Meteor.users.findOne({_id:aux_id}).profile[field.collection_property]
			else
				aux_property = Meteor.users.findOne({_id:aux_id}).emails[0].address
			'<a class="btn btn-default btn-xs" href="/admin/' +  'users' + '/' + aux_id + '/edit">' + aux_property + '</a>'
		else if typeof field.collection_property == 'string' and typeof adminCollectionObject(field.collection).findOne({_id:aux_id}) != 'undefined'
			aux_property = lookup field.collection_property adminCollectionObject(field.collection).findOne({_id:aux_id})
			'<a class="btn btn-default btn-xs" href="/admin/' +  field.collection + '/' + aux_id + '/edit">' + aux_property + '</a>'
	else if typeof adminCollectionObject(Session.get 'admin_collection_name') != 'undefined' and typeof adminCollectionObject(Session.get 'admin_collection_name').findOne({_id:_id}) != 'undefined'
		value = lookup field.name, adminCollectionObject(Session.get 'admin_collection_name').findOne({_id:_id})
		if typeof value == 'boolean' && value
			'<i class="fa fa-check"></i>'
		else
			value

UI.registerHelper 'admin_table_filters', ->
	if typeof AdminConfig != 'undefined' and typeof AdminConfig.collections[Session.get 'admin_collection_name'] != 'undefined' and typeof AdminConfig.collections[Session.get 'admin_collection_name'].tableColumns == 'object'
		columns = AdminConfig.collections[Session.get 'admin_collection_name'].tableColumns
		filters = _.map columns, (column) ->
			filterTemplates =
				text: 'adminTextFilter'
				number: 'adminNumberFilter'

			filterType = if typeof column.filterType == 'string' then column.filterType else 'text'
			{
				field: column.name
				label: column.label
				templateName: filterTemplates[filterType] or filterTemplates.text
			}
	filters

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
