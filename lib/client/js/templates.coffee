Template.adminPagesSort.helpers
	icon: ->
		collectionName = Session.get 'admin_collection_name'
		if collectionName and AdminPages[collectionName]
			sort = AdminPages[collectionName].getSort()
			if typeof sort[@field] == 'undefined'
				false
			else
				if sort[@field] == 1 then 'caret-up' else 'caret-down'

Template.adminPagesSort.events
	'click .admin_pages_sort': (e) ->
		collectionName = Session.get 'admin_collection_name'
		if collectionName and AdminPages[collectionName]
			sort = AdminPages[collectionName].getSort()
			if sort[@field] == -1
				delete sort[@field]
			else
				sort[@field] = if sort[@field] == 1 then -1 else 1
			AdminPages[collectionName].setSort sort

Template.adminTextFilter.events
	'change input': (e, t) ->
		value = t.firstNode.value
		if value.length > 0
			AdminPages[Session.get 'admin_collection_name']?.setFilter @field,
				$regex: value
				$options: 'i'
		else
			AdminPages[Session.get 'admin_collection_name']?.removeFilter @field

Template.adminNumberFilter.events
	'change input': (e, t) ->
		min = parseInt t.$('.js-filter-min').val(), 10
		max = parseInt t.$('.js-filter-max').val(), 10

		filter = {}
		if min then filter.$gt = min
		if max then filter.$lt = max

		if min or max
			AdminPages[Session.get 'admin_collection_name']?.setFilter @field, filter
		else
			AdminPages[Session.get 'admin_collection_name']?.removeFilter @field