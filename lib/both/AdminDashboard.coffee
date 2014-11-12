formatters = {
	del: (id) ->
		delHTML = formatters.link('#admin-delete-modal', 'hidden-xs btn btn-xs btn-danger btn-delete', formatters.icon('times'), 'data-toggle="modal" doc="{{_id}}"')
		delHTML += formatters.link('#admin-delete-modal', 'visible-xs btn btn-sm btn-danger btn-delete', formatters.icon('times'), 'data-toggle="modal" doc="{{_id}}"')
		delHTML

	edit: (id) ->
		collection = Session.get 'admin_collection'
		editHTML = formatters.link('/admin/' + collection + '/' + id + '/edit', 'hidden-xs btn btn-xs btn-primary', formatters.icon('pencil'))
		editHTML += formatters.link('/admin/' + collection + '/' + id + '/edit', 'visible-xs btn btn-sm btn-primary', formatters.icon('pencil'))
		editHTML

	getEmail: (email) ->
		email[0].address

	icon: (iconClass) ->
		'<i class="fa fa-' + iconClass + '"></i>';

	isAdmin: (id) ->
		formatters.icon('check') if Roles.userIsInRole(id, 'admin')

	link: (href, classes, content, extraLinkParams) ->
		'<a href="' + href + '" class="' + classes + '" ' + extraLinkParams + '>' + content + '</a>'

	mailLink: (email) ->
		formatters.link('mailto:' + formatters.getEmail(email), 'btn btn-default btn-xs', formatters.icon('envelope'))
}

AdminDashboard =
	schemas: {}
	formatters: formatters
	coreColumns: {
		users:[
			{title: 'Admin', data: '_id', render: formatters.isAdmin},
			{title: 'Email', data: 'emails', render: formatters.getEmail},
			{title: 'Mail', data: 'emails', render: formatters.mailLink, sortable: false},
			{title: 'Joined', data: 'createdAt'},
			{title: 'Edit', data: '_id', render: formatters.edit, sortable: false},
			{title: 'Delete', data: 'id', render: formatters.del, sortable: false}
		]
	}
	alertSuccess: (message)->
		Session.set 'adminSuccess', message
	alertFailure: (message)->
		Session.set 'adminError', message
	clearAlerts: ->
		Session.set 'adminSuccess', null
		Session.set 'adminError', null
		if typeof @.next == 'function'
			@next()

	checkAdmin: ->
		if not Roles.userIsInRole Meteor.userId(), ['admin']
			Meteor.call 'adminCheckAdmin'
			if (typeof AdminConfig?.nonAdminRedirectRoute == "string")
			  Router.go AdminConfig.nonAdminRedirectRoute
		if typeof @.next == 'function'
			@next()
	adminRoutes: ['adminDashboard','adminDashboardUsersNew','adminDashboardUsersView','adminDashboardUsersEdit','adminDashboardView','adminDashboardNew','adminDashboardEdit','adminDashboardDetail']
	collectionLabel: (collection)->
		if collection == 'Users'
			'Users'
		else if collection? and typeof AdminConfig.collections[collection].label == 'string'
			AdminConfig.collections[collection].label
		else Session.get 'admin_collection'


AdminDashboard.schemas.newUser = new SimpleSchema
	email:
		type: String
		label: "Email address"
	chooseOwnPassword:
		type: Boolean
		label: 'Let this user choose their own password with an email'
		defaultValue: true
	password:
		type: String
		label: 'Password'
		optional: true
	sendPassword:
		type: Boolean
		label: 'Send this user their password by email'
		optional: true

AdminDashboard.schemas.sendResetPasswordEmail = new SimpleSchema
	_id:
		type: String

AdminDashboard.schemas.changePassword = new SimpleSchema
	_id:
		type: String
	password:
		type: String
