@AdminTables = {}

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

Meteor.startup ->
	defaultColumns = [
		{data: '_id', title: 'ID'}
		{data: 'title', title: 'Title'}
	]

	_.each AdminConfig?.collections, (collection, name) ->
		columns = _.map collection.tableColumns, (column) ->
			data: column.name
			title: column.label

		if columns.length == 0
			columns = defaultColumns

		AdminTables[name] = new Tabular.Table
			name: name
			collection: adminCollectionObject(name)
			columns: columns