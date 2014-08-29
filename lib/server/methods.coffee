Meteor.methods
	adminInsertDoc: (doc,collection)->
		if Roles.userIsInRole this.userId, ['admin']
			Future = Npm.require('fibers/future');
			fut = new Future();

			global[collection].insert doc, (e,_id)->
				fut['return']( {e:e,_id:_id} )
			return fut.wait()

	adminUpdateDoc: (modifier,collection,_id)->
		if Roles.userIsInRole this.userId, ['admin']
			Future = Npm.require('fibers/future');
			fut = new Future();

			global[collection].update {_id:_id},modifier,(e,r)->
				console.log e
				console.log r
				fut['return']( {e:e,r:r} )
			return fut.wait()

	adminRemoveDoc: (collection,_id)->
		if Roles.userIsInRole this.userId, ['admin']
			if collection == 'Users'
				Meteor.users.remove {_id:_id}
			else
				global[collection].remove {_id:_id}


	adminNewUser: (doc) ->
		if Roles.userIsInRole this.userId, ['admin']
			emails = doc.email.split(',')
			_.each emails, (email)->
				user = {}
				user.email = email
				unless doc.chooseOwnPassword
					user.password = doc.password
					
				_id = Accounts.createUser user

				if doc.sendPassword && typeof AdminConfig.fromEmail != 'undefined'
					Email.send(
						to: user.email
						from: AdminConfig.fromEmail
						subject: 'Your accout has been created'
						html: 'You\'ve just had an account created for ' + Meteor.absoluteUrl() + ' with password ' + doc.password
						)

	adminUpdateUser: (modifier,_id)->
		if Roles.userIsInRole this.userId, ['admin']
			console.log modifier
			console.log _id
			Meteor.users.update {_id:_id}, modifier, (e,r)->

	adminSendResetPasswordEmail: (doc)->
		if Roles.userIsInRole this.userId, ['admin']
			console.log 'Changing password for user ' + doc._id
			Accounts.sendResetPasswordEmail(doc._id)

	adminChangePassword: (doc)->
		if Roles.userIsInRole this.userId, ['admin']
			console.log 'Changing password for user ' + doc._id
			Accounts.setPassword(doc._id, doc.password)
			label: 'Email user their new password'

	adminCheckAdmin: ->
		if !Roles.userIsInRole this.userId, ['admin']
			email = Meteor.users.findOne(_id:this.userId).emails[0].address
			if typeof AdminConfig != 'undefined' and typeof AdminConfig.adminEmails == 'object'
				adminEmails = AdminConfig.adminEmails
				if adminEmails.indexOf(email) > -1
					console.log 'Adding admin user: ' + email
					Roles.addUsersToRoles this.userId, ['admin']
			else if this.userId == Meteor.users.findOne({},{sort:{createdAt:1}})._id
				console.log 'Making first user admin: ' + email
				Roles.addUsersToRoles this.userId, ['admin']

	adminAddUserToRole: (_id,role)->
		if Roles.userIsInRole this.userId, ['admin']
			Roles.addUsersToRoles _id, role
	adminRemoveUserToRole: (_id,role)->
		if Roles.userIsInRole this.userId, ['admin']
			Roles.removeUsersFromRoles _id, role