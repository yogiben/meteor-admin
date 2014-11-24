AutoForm.hooks
	admin_insert:
		onSubmit: (insertDoc, updateDoc, currentDoc)->
			Meteor.call 'adminInsertDoc', insertDoc, Session.get('admin_collection_name'), (e,r)->
				if e
					AdminDashboard.alertFailure 'Error: ' + e
				else
					$('.btn-primary').removeClass('disabled')
					AutoForm.resetForm('admin_insert')
					adminCallback 'onInsert', [Session.get 'admin_collection_name', insertDoc, updateDoc, currentDoc], (collection) ->
						Router.go "/admin/#{collection}"
					AdminDashboard.alertSuccess 'Successfully created'
			false
		beginSubmit: (formId, template)->
			$('.btn-primary').addClass('disabled')
		onError: (operation, error, template)->
			AdminDashboard.alertFailure error.message

	admin_update:
		onSubmit: (insertDoc, updateDoc, currentDoc)->
			Meteor.call 'adminUpdateDoc', updateDoc, Session.get('admin_collection_name'), Session.get('admin_id'), (e,r)->
				if e
					console.log e
					AdminDashboard.alertFailure 'Error: ' + e
				else
					AdminDashboard.alertSuccess 'Updated'
					$('.btn-primary').removeClass('disabled')
					AutoForm.resetForm('admin_insert')
					$('.btn-primary').removeClass('disabled')
					adminCallback 'onUpdate', [Session.get 'admin_collection_name', insertDoc, updateDoc, currentDoc], (collection) ->
						Router.go "/admin/#{collection}"
			false
		beginSubmit: (formId, template)->
			$('.btn-primary').addClass('disabled')
		onError: (operation, error, template)->
			AdminDashboard.alertFailure error.message

	adminNewUser:
		onSuccess: (operation, result, template)->
			Router.go 'adminDashboardUsersView'
		onError: (operation, error, template)->
			AdminDashboard.alertFailure error.message

	admin_update_user:
		onSubmit: (insertDoc, updateDoc, currentDoc)->
			Meteor.call 'adminUpdateUser', updateDoc, Session.get('admin_id'), (e,r)->
				$('.btn-primary').removeClass('disabled')
			false
		onError: (operation, error, template)->
			AdminDashboard.alertFailure error.message

	adminSendResetPasswordEmail:
		onSuccess: (operation, result, template)->
			AdminDashboard.alertSuccess 'Email Sent'
		onError: (operation, error, template)->
			AdminDashboard.alertFailure error.message

	adminChangePassword:
		onSuccess: (operation, result, template)->
			AdminDashboard.alertSuccess 'Password reset'
		onError: (operation, error, template)->
			AdminDashboard.alertFailure error.message

# AutoForm.addHooks [
# 	"admin_insert"
# 	"admin_update"
# ],
# 	onSuccess: (operation, result, template)->
# 		AdminDashboard.alertSuccess 'Success'
	 
# 	onError: (operation, error, template) ->
# 		console.log error
# 		AdminDashboard.alertFailure 'Error: ' + error
