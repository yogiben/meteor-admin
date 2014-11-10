Template.AdminLayout.events
	'click .btn-delete': (e,t) ->
		_id = $(e.target).attr('doc')
		Session.set 'admin_id', _id
		if Session.equals 'admin_collection_name', 'Users'
			Session.set 'admin_doc', Meteor.users.findOne( _id:_id )
		else
			Session.set 'admin_doc', adminCollectionObject(Session.get 'admin_collection_name').findOne( _id:_id )

Template.AdminDeleteModal.events
	'click #confirm-delete': () ->
		collection = Session.get 'admin_collection_name'
		_id = Session.get 'admin_id'
		Meteor.call 'adminRemoveDoc', collection, _id, (e,r)->
			$('#admin-delete-modal').modal('hide')

Template.AdminDashboardUsersEdit.events
	'click .btn-add-role': (e,t) ->
		console.log 'adding user'
		Meteor.call 'adminAddUserToRole', $(e.target).attr('user'), $(e.target).attr('role')
	'click .btn-remove-role': (e,t) ->
		console.log 'removing user'
		Meteor.call 'adminRemoveUserToRole', $(e.target).attr('user'), $(e.target).attr('role')

Template.AdminHeader.events
	'click .btn-sign-out': () ->
		Meteor.logout ->
			Router.go('/')