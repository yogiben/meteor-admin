if Meteor.isClient
	Session.set 'admin_bootstrap_loaded', false
	Session.set 'admin_fontawesome_loaded', false

@AdminController = RouteController.extend
	layoutTemplate: 'AdminLayout'
	waitOn: ->
		[
			Meteor.subscribe 'adminUsers'
			Meteor.subscribe 'adminUser'
			Meteor.subscribe 'adminCollectionsCount'
		]
	onBeforeAction: ->
		Session.set 'adminSuccess', null
		Session.set 'adminError', null

		Session.set 'admin_title', ''
		Session.set 'admin_subtitle', ''
		Session.set 'admin_collection_page', null
		Session.set 'admin_collection_name', null
		Session.set 'admin_id', null
		Session.set 'admin_doc', null

		if not Roles.userIsInRole Meteor.userId(), ['admin']
			Meteor.call 'adminCheckAdmin'
			if typeof AdminConfig?.nonAdminRedirectRoute == 'string'
				Router.go AdminConfig.nonAdminRedirectRoute
		
		if AdminConfig.lazyLoad?.bootstrap and not Session.get('admin_bootstrap_loaded')
			$("<link/>", {
				rel: "stylesheet"
				type: "text/css"
				href: "//maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css"
			}).appendTo('head')
			Session.set 'admin_bootstrap_loaded', true
		
		if AdminConfig.lazyLoad?.fontawesome and not Session.get('admin_fontawesome_loaded')
			$("<link/>", {
				rel: "stylesheet"
				type: "text/css"
				href: "//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css"
			}).appendTo('head')
			Session.set 'admin_fontawesome_loaded', true
		
		@next()


Router.route "adminDashboard",
	path: "/admin"
	template: "AdminDashboard"
	controller: "AdminController"
	action: ->
		@render()
	onAfterAction: ->
		Session.set 'admin_title', 'Dashboard'
		Session.set 'admin_collection_name', ''
		Session.set 'admin_collection_page', ''

Router.route "adminDashboardUsersNew",
	path: "/admin/Users/new"
	template: "AdminDashboardUsersNew"
	controller: 'AdminController'
	action: ->
		@render()
	onAfterAction: ->
		Session.set 'admin_title', 'Users'
		Session.set 'admin_subtitle', 'Create new user'
		Session.set 'admin_collection_page', 'New'
		Session.set 'admin_collection_name', 'Users'

Router.route "adminDashboardUsersEdit",
	path: "/admin/Users/:_id/edit"
	template: "AdminDashboardUsersEdit"
	controller: "AdminController"
	data: ->
		user: Meteor.users.find(@params._id).fetch()
		roles: Roles.getRolesForUser @params._id
		otherRoles: _.difference _.map(Meteor.roles.find().fetch(), (role) -> role.name), Roles.getRolesForUser(@params._id)
	action: ->
		@render()
	onAfterAction: ->
		Session.set 'admin_title', 'Users'
		Session.set 'admin_subtitle', 'Edit user ' + @params._id
		Session.set 'admin_collection_page', 'edit'
		Session.set 'admin_collection_name', 'Users'
		Session.set 'admin_id', @params._id
		Session.set 'admin_doc', Meteor.users.findOne({_id:@params._id})

Router.route "adminDashboardView",
	path: "/admin/:collection"
	template: "AdminDashboardViewWrapper"
	controller: "AdminController"
	data: ->
  		admin_table: AdminTables[@params.collection]
	action: ->
		@render()
	onAfterAction: ->
		Session.set 'admin_title', @params.collection
		Session.set 'admin_subtitle', 'View'
		Session.set 'admin_collection_name', @params.collection

Router.route "adminDashboardNew",
	path: "/admin/:collection/new"
	template: "AdminDashboardNew"
	controller: "AdminController"
	action: ->
		@render()
	onAfterAction: ->
		Session.set 'admin_title', AdminDashboard.collectionLabel(@params.collection)
		Session.set 'admin_subtitle', 'Create new'
		Session.set 'admin_collection_page', 'new'
		Session.set 'admin_collection_name', @params.collection.charAt(0).toUpperCase() + @params.collection.slice(1)
	data: ->
		admin_collection: adminCollectionObject @params.collection

Router.route "adminDashboardEdit",
	path: "/admin/:collection/:_id/edit"
	template: "AdminDashboardEdit"
	controller: "AdminController"
	waitOn: ->
		Meteor.subscribe('adminCollectionDoc', @params.collection, parseID(@params._id))
	action: ->
		@render()
	onAfterAction: ->
		Session.set 'admin_title', AdminDashboard.collectionLabel @params.collection
		Session.set 'admin_subtitle', 'Edit ' + @params._id
		Session.set 'admin_collection_page', 'edit'
		Session.set 'admin_collection_name', @params.collection.charAt(0).toUpperCase() + @params.collection.slice(1)
		Session.set 'admin_id', parseID(@params._id)
		Session.set 'admin_doc', adminCollectionObject(@params.collection).findOne _id : parseID(@params._id)
	data: ->
		admin_collection: adminCollectionObject @params.collection
