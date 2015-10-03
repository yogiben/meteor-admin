@AdminTables = {}

adminTablesDom = '<"box"<"box-header"<"box-toolbar"<"pull-left"<lf>><"pull-right"p>>><"box-body"t>>'

adminEditButton = {
	data: '_id'
	title: 'Edit'
	createdCell: (node, cellData, rowData) ->
		$(node).html(Blaze.toHTMLWithData Template.adminEditBtn, {_id: cellData}, node)
	width: '40px'
	orderable: false
}
adminDelButton = {
	data: '_id'
	title: 'Delete'
	createdCell: (node, cellData, rowData) ->
		$(node).html(Blaze.toHTMLWithData Template.adminDeleteBtn, {_id: cellData}, node)
	width: '40px'
	orderable: false
}

adminEditDelButtons = [
	adminEditButton,
	adminDelButton
]

defaultColumns = () -> [
  data: '_id',
  title: 'ID'
]

AdminTables.Users = new Tabular.Table
	# Modify selector to allow search by email
	changeSelector: (selector, userId) ->
		$or = selector['$or']
		$or and selector['$or'] = _.map $or, (exp) ->
			if exp.emails?['$regex']?
				emails: $elemMatch: address: exp.emails
			else
				exp
		selector

	name: 'Users'
	collection: Meteor.users
	columns: _.union [
		{
			data: '_id'
			title: 'Admin'
			# TODO: use `tmpl`
			createdCell: (node, cellData, rowData) ->
				$(node).html(Blaze.toHTMLWithData Template.adminUsersIsAdmin, {_id: cellData}, node)
			width: '40px'
		}
		{
			data: 'emails'
			title: 'Email'
			render: (value) ->
				value[0].address
			searchable: true
		}
		{
			data: 'emails'
			title: 'Mail'
			# TODO: use `tmpl`
			createdCell: (node, cellData, rowData) ->
				$(node).html(Blaze.toHTMLWithData Template.adminUsersMailBtn, {emails: cellData}, node)
			width: '40px'
		}
		{ data: 'createdAt', title: 'Joined' }
	], adminEditDelButtons
	dom: adminTablesDom

adminTablePubName = (collection) ->
	"admin_tabular_#{collection}"

adminCreateTables = (collections) ->
	_.each AdminConfig?.collections, (collection, name) ->
		_.defaults collection, {
			showEditColumn: true
			showDelColumn: true
		}

		columns = _.map collection.tableColumns, (column) ->
			if column.template
				createdCell = (node, cellData, rowData) ->
					$(node).html ''
					Blaze.renderWithData(Template[column.template], {value: cellData, doc: rowData}, node)

			data: column.name
			title: column.label
			createdCell: createdCell

		if columns.length == 0
			columns = defaultColumns()

		if collection.showEditColumn
			columns.push(adminEditButton)
		if collection.showDelColumn
			columns.push(adminDelButton)

		AdminTables[name] = new Tabular.Table
			name: name
			collection: adminCollectionObject(name)
			pub: collection.children and adminTablePubName(name)
			sub: collection.sub
			columns: columns
			extraFields: collection.extraFields
			dom: adminTablesDom

adminCreateRoutes = (collections) ->
	_.each collections, adminCreateRouteView
	_.each collections,	adminCreateRouteNew
	_.each collections, adminCreateRouteEdit

adminCreateRouteView = (collection, collectionName) ->
	Router.route "adminDashboard#{collectionName}View",
		adminCreateRouteViewOptions collection, collectionName

adminCreateRouteViewOptions = (collection, collectionName) ->
	options =
		path: "/admin/#{collectionName}"
		template: "AdminDashboardViewWrapper"
		controller: "AdminController"
		data: ->
  		admin_table: AdminTables[collectionName]
		action: ->
			@render()
		onAfterAction: ->
			Session.set 'admin_title', collectionName
			Session.set 'admin_subtitle', 'View'
			Session.set 'admin_collection_name', collectionName
			collection.routes?.view?.onAfterAction
	_.defaults options, collection.routes?.view

adminCreateRouteNew = (collection, collectionName) ->
	Router.route "adminDashboard#{collectionName}New",
		adminCreateRouteNewOptions collection, collectionName

adminCreateRouteNewOptions = (collection, collectionName) ->
	options =
		path: "/admin/#{collectionName}/new"
		template: "AdminDashboardNew"
		controller: "AdminController"
		action: ->
			@render()
		onAfterAction: ->
			Session.set 'admin_title', AdminDashboard.collectionLabel collectionName
			Session.set 'admin_subtitle', 'Create new'
			Session.set 'admin_collection_page', 'new'
			Session.set 'admin_collection_name', collectionName
			collection.routes?.new?.onAfterAction
		data: ->
			admin_collection: adminCollectionObject collectionName
	_.defaults options, collection.routes?.new

adminCreateRouteEdit = (collection, collectionName) ->
	Router.route "adminDashboard#{collectionName}Edit",
		adminCreateRouteEditOptions collection, collectionName

adminCreateRouteEditOptions = (collection, collectionName) ->
	options =
		path: "/admin/#{collectionName}/:_id/edit"
		template: "AdminDashboardEdit"
		controller: "AdminController"
		waitOn: ->
			Meteor.subscribe 'adminCollectionDoc', collectionName, parseID(@params._id)
			collection.routes?.edit?.waitOn
		action: ->
			@render()
		onAfterAction: ->
			Session.set 'admin_title', AdminDashboard.collectionLabel collectionName
			Session.set 'admin_subtitle', 'Edit ' + @params._id
			Session.set 'admin_collection_page', 'edit'
			Session.set 'admin_collection_name', collectionName
			Session.set 'admin_id', parseID(@params._id)
			Session.set 'admin_doc', adminCollectionObject(collectionName).findOne _id : parseID(@params._id)
			collection.routes?.edit?.onAfterAction
		data: ->
			admin_collection: adminCollectionObject collectionName
	_.defaults options, collection.routes?.edit

adminPublishTables = (collections) ->
	_.each collections, (collection, name) ->
		if not collection.children then return undefined
		Meteor.publishComposite adminTablePubName(name), (tableName, ids, fields) ->
			check tableName, String
			check ids, Array
			check fields, Match.Optional Object

			extraFields = _.reduce collection.extraFields, (fields, name) ->
				fields[name] = 1
				fields
			, {}
			_.extend fields, extraFields

			@unblock()

			find: ->
				@unblock()
				adminCollectionObject(name).find {_id: {$in: ids}}, {fields: fields}
			children: collection.children

Meteor.startup ->
	adminCreateTables AdminConfig?.collections
	adminCreateRoutes AdminConfig?.collections
	adminPublishTables AdminConfig?.collections if Meteor.isServer
