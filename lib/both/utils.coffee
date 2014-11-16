@adminCollectionObject = (collection) ->
	if typeof AdminConfig.collections[collection] != 'undefined' and typeof AdminConfig.collections[collection].collectionObject != 'undefined'
		AdminConfig.collections[collection].collectionObject
	else
		if Meteor.isServer
			global[collection]
		else
			window[collection]