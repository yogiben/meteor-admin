Meteor.startup ->
	if typeof AdminConfig != 'undefined' && typeof AdminConfig.adminEmails != 'undefined'
		adminEmails = AdminConfig.adminEmails
		_.each adminEmails, (adminEmail) ->
			if Meteor.users.findOne(emails:
				$elemMatch:
					address: adminEmail
			)
				console.log 'User exists: ' + adminEmail
				Roles.addUsersToRoles(Meteor.users.findOne({emails:{$elemMatch: {address: adminEmail}}})._id, ["admin"])
			else
				console.log "Creating admin user " + adminEmail
				_id = Accounts.createUser(
					email: adminEmail
					profile: {}
					#For local
					password: 'code2create'
				)
				Roles.addUsersToRoles _id, ["admin"]
				Accounts.sendEnrollmentEmail _id
			return