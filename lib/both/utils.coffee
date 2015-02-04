@adminCollectionObject = (collection) ->
	if typeof AdminConfig.collections[collection] != 'undefined' and typeof AdminConfig.collections[collection].collectionObject != 'undefined'
		AdminConfig.collections[collection].collectionObject
	else
		lookup collection

@adminRoute = (path = '') ->
  if typeof AdminConfig?.baseRoute != 'undefined'
    AdminConfig.baseRoute + path
  else
    console.log("Not using AdminConfig", typeof AdminConfig)
    console.trace()
    '/admin' + path

@adminCallback = (name, args, callback) ->
	stop = false
	if typeof AdminConfig?.callbacks?[name] == 'function'
		stop = AdminConfig.callbacks[name](args...) is false
	if typeof callback == 'function'
		callback args... unless stop

@adminCollectionRoute = (collectionName) ->
	'admin_collections_' + collectionName + '_home0'

@lookup = (obj, root, required=true) ->
	if typeof root == 'undefined'
		root = if Meteor.isServer then global else window
	if typeof obj == 'string'
		ref = root
		arr = obj.split '.'
		continue while arr.length and (ref = ref[arr.shift()])
		if not ref and required
			throw new Error(obj + ' is not in the ' + root.toString())
		else
			return ref
	return obj
