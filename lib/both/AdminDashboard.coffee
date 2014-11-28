AdminDashboard =
	schemas: {}
	sidebarItems: []
	collectionItems: []
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
		else Session.get 'admin_collection_name'

	addSidebarItem: (title, url, options) ->
		item = title: title
		if _.isObject(url) and typeof options == 'undefined'
			item.options = url
		else
			item.url = url
			item.options = options

		@sidebarItems.push item

	addCollectionItem: (fn) ->
		@collectionItems.push fn


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
