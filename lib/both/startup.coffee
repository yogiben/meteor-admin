Meteor.startup ->
	@AdminUsersCollection =
		collectionObject: Meteor.users
		icon: 'user'

	if typeof AdminConfig != 'undefined' and typeof AdminConfig.collections != 'undefined'
		collections = AdminConfig.collections
	else
		collections = {}

	collections.Users = AdminUsersCollection

	@AdminPages = _.map collections, (collection, collectionName) ->
		templateName = 'AdminDashboardView_' + collectionName
		if Meteor.isClient
			Template.AdminDashboardView.copyAs(templateName)

		new Meteor.Pagination adminCollectionObject(collectionName),
			name: 'admin_collections_' + collectionName
			router: 'iron-router'
			homeRoute: '/admin/' + collectionName
			route: '/admin/' + collectionName
			routerTemplate: templateName
			templateName: templateName
			routeSettings: (router) ->
				router.action = ->
					Session.set 'admin_title', AdminDashboard.collectionLabel(collectionName)
					Session.set 'admin_subtitle', 'View'
					Session.set 'admin_collection_page', ''
					Session.set 'admin_collection_name', collectionName
					router.render()
			routerLayout: 'AdminLayout'
			itemTemplate: 'adminPagesItem'
			# force meteor-pages to render a table
			table: {}