Meteor.startup ->
	@AdminUsersCollection =
		collectionObject: Meteor.users
		icon: 'user'

	if typeof AdminConfig != 'undefined' and typeof AdminConfig.collections != 'undefined'
		collections = AdminConfig.collections
	else
		collections = {}

	collections.Users = AdminUsersCollection

	@AdminPages = {}
	_.each collections, (collection, collectionName) ->
		templateName = 'AdminDashboardView_' + collectionName
		if Meteor.isClient
			Template.AdminDashboardView.copyAs(templateName)

		AdminPages[collectionName] = 
			page: new Meteor.Pagination adminCollectionObject(collectionName),
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
				availableSettings:
					sort: true
					filters: true
				# force meteor-pages to render a table
				table: {}

		if Meteor.isClient
			AdminPages[collectionName].sort = new Tracker.Dependency
			AdminPages[collectionName].getSort = ->
				@sort.depend()
				_.clone @page.sort
			AdminPages[collectionName].setSort = (sort) ->
				@page.set sort: sort
				@sort.changed()

			AdminPages[collectionName].setFilter = (field, filter) ->
				filters = _.clone @page.filters
				filters[field] = filter
				@page.set filters: filters
			AdminPages[collectionName].removeFilter = (field) ->
				filters = _.clone @page.filters
				if filters[field]
					delete filters[field]
					@page.set filters: filters
