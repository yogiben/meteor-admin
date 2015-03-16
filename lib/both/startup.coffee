@AdminTables = {}

adminTablesDom = '<"box"<"box-header"<"box-toolbar"<"pull-left"<lf>><"pull-right"p>>><"box-body"t>>'
adminEditDelButtons = [
	{
		data: '_id'
		title: 'Edit'
		createdCell: (node, cellData, rowData) ->
			$(node).html(Blaze.toHTMLWithData Template.adminEditBtn, {_id: cellData}, node)
		width: '40px'
		orderable: false
	}
	{
		data: '_id'
		title: 'Delete'
		createdCell: (node, cellData, rowData) ->
			$(node).html(Blaze.toHTMLWithData Template.adminDeleteBtn, {_id: cellData}, node)
		width: '40px'
		orderable: false
	}
]

defaultColumns = [
  data: '_id',
  title: 'ID'
]

AdminTables.Users = new Tabular.Table
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
		columns = _.map collection.tableColumns, (column) ->
			if column.template
				createdCell = (node, cellData, rowData) ->
					$(node).html(Blaze.toHTMLWithData Template[column.template], {value: cellData, doc: rowData}, node)

			data: column.name
			title: column.label
			createdCell: createdCell

		if columns.length == 0
			columns = defaultColumns

		AdminTables[name] = new Tabular.Table
			name: name
			collection: adminCollectionObject(name)
			pub: collection.children and adminTablePubName(name)
			sub: collection.sub
			columns: _.union columns, adminEditDelButtons
			extraFields: collection.extraFields
			dom: adminTablesDom

adminPublishTables = (collections) ->
	_.each collections, (collection, name) ->
		if not collection.children then return undefined
		Meteor.publishComposite adminTablePubName(name), (tableName, ids, fields) ->
			check tableName, String
			check ids, Array
			check fields, Match.Optional Object

			if not Roles.userIsInRole this.userId, ['admin']
				return undefined

			@unblock()

			if collection.extraFields?
				_.forEach collection.extraFields, (field) ->
					fields[field] = 1

			find: ->
				@unblock()
				adminCollectionObject(name).find {_id: {$in: ids}}, {fields: fields}
			children: collection.children

Meteor.startup ->
	adminCreateTables AdminConfig?.collections
	adminPublishTables AdminConfig?.collections if Meteor.isServer
