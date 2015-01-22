@AdminTables = {}

adminTablesDom = '<"box"<"box-header"<"box-toolbar"<"pull-left"<lf>><"pull-right"p>>><"box-body"t>>'

AdminTables.Users = new Tabular.Table
	name: 'Users'
	collection: Meteor.users
	columns: [
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
		{
			data: '_id'
			title: 'Edit'
			createdCell: (node, cellData, rowData) ->
				$(node).html(Blaze.toHTMLWithData Template.adminUsersEditBtn, {_id: cellData}, node)
			width: '40px'
			orderable: false
		}
		{
			data: '_id'
			title: 'Delete'
			createdCell: (node, cellData, rowData) ->
				$(node).html(Blaze.toHTMLWithData Template.adminUsersDeleteBtn, {_id: cellData}, node)
			width: '40px'
			orderable: false
		}
	]
	dom: adminTablesDom

adminTablePubName = (collection) ->
	"admin_tabular_#{collection}"

adminCreateTables = (collections) ->
	_.each AdminConfig?.collections, (collection, name) ->
		columns = _.map collection.tableColumns, (column) ->
			data: column.name
			title: column.label

		if columns.length == 0
			columns = defaultColumns

		AdminTables[name] = new Tabular.Table
			name: name
			collection: adminCollectionObject(name)
			pub: collection.children and adminTablePubName(name)
			columns: columns
			extraFields: collection.extraFields
			dom: adminTablesDom

adminPublishTables = (collections) ->
	_.each collections, (collection, name) ->
		if not collection.children then return undefined
		Meteor.publishComposite adminTablePubName(name), (tableName, ids, fields) ->
			check tableName, String
			check ids, Array
			check fields, Match.Optional Object

			@unblock()

			find: ->
				@unblock()
				adminCollectionObject(name).find {_id: {$in: ids}}, {fields: fields}
			children: collection.children

Meteor.startup ->
	adminCreateTables AdminConfig?.collections
	adminPublishTables AdminConfig?.collections if Meteor.isServer