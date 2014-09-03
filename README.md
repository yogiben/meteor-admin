Meteor Admin
============
`$ meteor add yogiben:admin`

**Work in progress**

A complete admin dashboard solution for meteor built off the [roles](https://github.com/alanning/meteor-roles/) and [autoform](https://github.com/aldeed/meteor-autoform) packages and frontend from the open source admin dashboard template, [Admin LTE](https://github.com/almasaeed2010/AdminLTE).

**Feedback Welcome.** Please create an issue.

![alt tag](https://raw.githubusercontent.com/yogiben/meteor-admin/master/readme/screenshot1.png)

![alt tag](https://raw.githubusercontent.com/yogiben/meteor-admin/master/readme/screenshot2.png)

### Getting started ###

#### 1. Install ####
Download to your packages directory and run `meteor add yogiben:admin` then go to `/admin` for the setup wizzard.

#### 2. Config ####
The simplest possible config with one, 'Posts', collection.
#####Both#####
```
AdminConfig = {
  collections: {
    Posts: {}
  }
};
```
This config will make the **first user** admin.

You can also set the adminEmails property which will will override this.
```
AdminConfig = {
  name: 'My App'
  adminEmails: ['ben@code2create.com']
  collections: {
    Posts: {}
  }
};
```
#### 3. Define your data models ####
If you are unfamiliar with [autoform](https://github.com/aldeed/meteor-autoform) or [collection2](https://github.com/aldeed/meteor-collection2) you should check them out now.

You need to define and attach a schema to the collections that you want to edit via the admin dashboard. Check out the [documentation](https://github.com/aldeed/meteor-collection2).
```
Schemas = {}

Posts = new Meteor.Collection('posts');

Schemas.Posts = new SimpleSchema
	title:
		type:String
		max: 60
	content:
		type: String
		autoform:
			rows: 5
	createdAt: 
		type: Date
		label: 'Date'
		autoValue: ->
			if this.isInsert
				return new Date()
	owner: 
		type: String
		regEx: SimpleSchema.RegEx.Id
		autoValue: ->
			if this.isInsert
				return Meteor.userId()
		autoform:
			options: ->
				_.map Meteor.users.find().fetch(), (user)->
					label: user.emails[0].address
					value: user._id

Posts.attachSchema(Schemas.Posts)
```
#### 4. Enjoy ####
Go to `/admin`. If you are not made an admin, re-read step 2.

### Customization ###
The admin dashboard is heavily customisable. Most of the possibilities are represented in the config option below.
```
AdminConfig =
    collections : 
        Posts: {
            icon: 'pencil'
            tableColumns: [
              {label: 'Title',name:'title'}
              {label: Published',name:'published'
              {label:'User',name:'owner',collection:'Users'}
            ]
            auxCollections: ['Attachments']
            templates:
              new:
                name: 'postWYSIGEditor'
                data:
                  post: Session.get 'admin_doc'
              edit:
                name: 'postWYSIGEditor'
                data:
                  post: Session.get 'admin_doc'
        },
        Comments: {
            icon: 'comment'
            auxCollections: ['Posts']
            omitFields: ['owner']
            tableColumns: [
              {label: 'Content';name:'content'}
              {label:'Post';name:'message',collection: 'Posts',collection_property:'title'}
              {label:'User',name:'owner',collection:'Users'}
            ]
            showWidget: false
        }
    autoForm: 
        omitFields: ['createdAt','updatedAt']
    dashboard:
        homeUrl: '/dashboard'
        widgets: [
                    {
            template: 'adminCollectionWidget'
            data:
              collection: 'Posts'
              class: 'col-lg-3 col-xs-6'
          }
          {
            template: 'adminUserWidget'
            data:
              class: 'col-lg-3 col-xs-6'
          }
        ]
```

#### Collections ####
`AdminConfig.collections` tells the dashboard which collections to manage based on the global variable name.
```
AdminConfig =
  collections:
    Posts: {},
    Comments: {}
  }
```
It is possible to configure the way the collection is managed.
```
Comments: {
            icon: 'comment'
            auxCollections: ['Posts']
            omitFields: ['updatedAt']
            tableColumns: [
              {label: 'Content';name:'content'}
              {label:'Post';name:'post',collection: 'Posts',collection_property:'title'}
              {label:'User',name:'owner',collection:'Users'}
            ]
            showWidget: false
            color: 'red'
        }
```
`icon` is the icon code from [Font Awesome](http://fortawesome.github.io/Font-Awesome/icons/).

`auxCollections` is an array of the names of the other collections that this collection that this depends on. For example, comments are always associated with posts and so we need to publish and subscribe to the `Posts` collection to display the title etc. in the admin dashboard.

`tableColumns` an array of objects that describe the columns that will appear in the admin dashboard.

* `{label: 'Content';name:'content'}` will display the `content` property of the mongo doc.
* `{label:'Post';name:'post',collection: 'Posts',collection_property:'title'}` will look for a doc in the 'Posts' collection with the `_id` defined by the comment's `post` property. The `title` of this document will be displayed.
* `{label:'User',name:'owner',collection:'Users'}` will display the user's email when the `owner` property is the `_id` of the user.

`omitFields` hides fields that we don't want appearing in the add / edit screens like 'updatedAt' for example. From [AutoForm](https://github.com/aldeed/meteor-autoform).

`showWidget` when set to false hides the corresponding widget from the dashboard.

`color` styles the widget. See the [LTE Admin documentation](http://almsaeedstudio.com/preview/).

#### Custom Templates ####
The default admin templates are autoForm instances based on the schemas assigned to the collections. If they don't do the job, you specify a custom template to use for each of the `new`,`edit` and `view` screens for each collection.
```
AdminConfig =
    ...
    collections : 
        Posts: {
            templates:
              new:
                name: 'postWYSIGEditor'
              edit:
                name: 'postWYSIGEditor'
                data:
                  post: Session.get 'admin_doc'
```
The `/admin/Posts/new` and `/admin/Posts/edit` will not use the `postWYSIGEditor` template that you've defined somewhere in your code. The `edit` view will be rendered with a data context (here the document being edited).

Custom templates are most used when you need to use an {{#autoForm}} instead of the default {{> quickForm}}.

#### Autoform ####
```
AdminConfig =
    ...
    autoForm: 
        omitFields: ['createdAt','updatedAt']
```
Here you can specify globally the fields that should never appear in your `new` and `update` views. This is typically meta information likes dates.

**Important** don't omit fields unless the schema specifies either an `autoValue` or `optional` is set to `true`. See [autoForm](https://github.com/aldeed/meteor-autoform).

#### Dashboard ####
Here you can customise the look and feel of the dashboard.
```
AdminConfig =
    ...
    dashboard:
        homeUrl: '/dashboard'
        skin: 'black'
        widgets: [
                    {
            template: 'adminCollectionWidget'
            data:
              collection: 'Posts'
              class: 'col-lg-3 col-xs-6'
          }
          {
            template: 'adminUserWidget'
            data:
              class: 'col-lg-3 col-xs-6'
          }
        ]
```
`homeUrl` is the `href` property of the 'Home' button. Defaults to `/`.

`skin` defaults to 'blue' but there is also a black skin avaiable.

`widgets` is an array of objects specifying template names and data contexts. Make sure to specify the `class` in the data context. If set, the `widgets` property will override the collection widgets which appear by default.
