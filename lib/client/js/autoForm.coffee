AutoForm.hooks
	admin_insert:
		onSubmit: (insertDoc, updateDoc, currentDoc)->
			Meteor.call 'adminInsertDoc', insertDoc, Session.get('admin_collection'), (e,r)->
				console.log 'error: ' + e
				console.log  r
				unless e
					$('.btn-primary').removeClass('disabled')
					AutoForm.resetForm('admin_insert')
					Router.go '/admin/' + Session.get('admin_collection')
			false
		beginSubmit: (formId, template)->
			$('.btn-primary').addClass('disabled')

	admin_update:
		onSubmit: (insertDoc, updateDoc, currentDoc)->
			Meteor.call 'adminUpdateDoc', updateDoc, Session.get('admin_collection'), Session.get('admin_id'), (e,r)->
				console.log 'error: ' + e
				console.log  r
				unless e
					$('.btn-primary').removeClass('disabled')
					AutoForm.resetForm('admin_insert')
			false
		beginSubmit: (formId, template)->
			$('.btn-primary').addClass('disabled')

	admin_update_user:
		onSubmit: (insertDoc, updateDoc, currentDoc)->
			Meteor.call 'adminUpdateUser', updateDoc, Session.get('admin_id'), (e,r)->
				
			
			

	adminNewUser:
		onSuccess: (operation, result, template)->
			Router.go 'adminDashboardUsersView'
		onError: (operation, error, template)->
			AdminDashboard.alertFailure error

	adminSendResetPasswordEmail:
		onSuccess: (operation, result, template)->
			AdminDashboard.alertSuccess 'Email Sent'
		onError: (operation, error, template)->
			AdminDashboard.alertFailure error

	adminChangePassword:
		onSuccess: (operation, result, template)->
			AdminDashboard.alertSuccess 'Password reset'
		onError: (operation, error, template)->
			AdminDashboard.alertFailure error
