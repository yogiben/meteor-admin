Router.map ->
  @route "adminDashboard",
    path: "/admin"
    template: "AdminDashboard"
    layoutTemplate: "AdminLayout"
    waitOn: ->
      [
        Meteor.subscribe 'adminUsers'
        Meteor.subscribe 'adminAllCollections'
        Meteor.subscribe 'adminUser'
      ]
    action: ->
      @render()
    onAfterAction: ->
      Session.set 'admin_title', 'Dashboard'
      Session.set 'admin_collection_name', ''
      Session.set 'admin_collection_page', ''
    # onBeforeAction: ->
      # AccountsEntry.signInRequired this
  @route "adminDashboardUsersNew",
    path: "/admin/Users/new"
    template: "AdminDashboardUsersNew"
    layoutTemplate: "AdminLayout"
    waitOn: ->
      [
        Meteor.subscribe 'adminUsers'
        Meteor.subscribe 'adminUser'
      ]
    action: ->
      @render()
    onAfterAction: ->
      Session.set 'admin_title', 'Users'
      Session.set 'admin_subtitle', 'Create new user'
      Session.set 'admin_collection_page', 'New'
      Session.set 'admin_collection_name', 'Users'

  @route "adminDashboardUsersEdit",
    path: "/admin/Users/:_id/edit"
    template: "AdminDashboardUsersEdit"
    layoutTemplate: "AdminLayout"
    waitOn: ->
      [
        Meteor.subscribe 'adminUsers'
        Meteor.subscribe 'adminUser'
      ]
    data: ->
      user : Meteor.users.find({_id:@params._id}).fetch()
      roles: Roles.getRolesForUser @params._id
      otherRoles: _.difference _.map( Meteor.roles.find().fetch(), (role)-> role.name), Roles.getRolesForUser(@params._id)
    action: ->
      @render()
    onAfterAction: ->
      Session.set 'admin_title', 'Users'
      Session.set 'admin_subtitle', 'Edit user ' + @params._id
      Session.set 'admin_collection_page', 'edit'
      Session.set 'admin_collection_name', 'Users'
      Session.set 'admin_id', @params._id
      Session.set 'admin_doc', Meteor.users.findOne({_id:@params._id})

  @route "adminDashboardNew",
    path: "/admin/:collection/new"
    template: "AdminDashboardNew"
    layoutTemplate: "AdminLayout"
    waitOn: ->
      [
        Meteor.subscribe('adminAuxCollections', @params.collection)
        Meteor.subscribe('adminUsers')
        Meteor.subscribe 'adminUser'
      ]
    action: ->
      @render()
    onAfterAction: ->
      Session.set 'admin_title', AdminDashboard.collectionLabel(@params.collection)
      Session.set 'admin_subtitle', 'Create new'
      Session.set 'admin_collection_page', 'new'
      Session.set 'admin_collection_name', @params.collection.charAt(0).toUpperCase() + @params.collection.slice(1)
    data: -> { admin_collection: adminCollectionObject(@params.collection) }
    # onBeforeAction: ->
      # AccountsEntry.signInRequired this
  @route "adminDashboardEdit",
    path: "/admin/:collection/:_id/edit"
    template: "AdminDashboardEdit"
    layoutTemplate: "AdminLayout"
    waitOn: ->
      [
        Meteor.subscribe('adminCollection', @params.collection)
        Meteor.subscribe('adminAuxCollections', @params.collection)
        Meteor.subscribe('adminUsers')
        Meteor.subscribe 'adminUser'
      ]
    action: ->
      @render()
    onAfterAction: ->
      Session.set 'admin_title', AdminDashboard.collectionLabel(@params.collection)
      Session.set 'admin_subtitle', 'Edit ' + @params._id
      Session.set 'admin_collection_page', 'edit'
      Session.set 'admin_collection_name', @params.collection.charAt(0).toUpperCase() + @params.collection.slice(1)
      # Session.set 'admin_collection', adminCollectionObject(@params.collection)
      Session.set 'admin_id', @params._id
      Session.set 'admin_doc', adminCollectionObject(@params.collection).findOne _id : @params._id
    data: -> { admin_collection: adminCollectionObject(@params.collection) }
    # onBeforeAction: ->
      # AccountsEntry.signInRequired this

Router.onBeforeAction AdminDashboard.checkAdmin, {only: AdminDashboard.adminRoutes}
Router.onBeforeAction AdminDashboard.clearAlerts, {only: AdminDashboard.adminRoutes}