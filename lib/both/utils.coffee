@adminCollectionObject = (collection) ->
	if typeof AdminConfig.collections[collection] != 'undefined' and typeof AdminConfig.collections[collection].collectionObject != 'undefined'
		AdminConfig.collections[collection].collectionObject
	else
		if Meteor.isServer
			global[collection]
		else
			window[collection]

@adminCallback = (name, args, callback) ->
	stop = false
	if typeof AdminConfig?.callbacks?[name] == 'function'
		stop = AdminConfig.callbacks[name](args...) is false
	if typeof callback == 'function'
		callback args... unless stop