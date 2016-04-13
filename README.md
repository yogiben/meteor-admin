Meteor Admin
============
`$ meteor add yogiben:admin`

To get a working example, clone and run my [Meteor starter](https://github.com/yogiben/meteor-starter) repo and then go to `/admin`.

A complete admin dashboard solution for meteor built off the [iron-router](https://github.com/iron-meteor/iron-router),  [roles](https://github.com/alanning/meteor-roles/) and [autoform](https://github.com/aldeed/meteor-autoform) packages and frontend from the open source admin dashboard template, [Admin LTE](https://github.com/almasaeed2010/AdminLTE).

**Feedback Welcome.** Please create an issue.

![alt tag](https://raw.githubusercontent.com/yogiben/meteor-admin/master/readme/screenshot1.png)

![alt tag](https://raw.githubusercontent.com/yogiben/meteor-admin/master/readme/screenshot2.png)

Maintained by [Meteor Factory](https://meteorfactory.io). Professional Meteor development.

[![Meteor admin](https://raw.githubusercontent.com/yogiben/meteor-admin/master/readme/meteor-factory.jpg)](http://meteorfactory.io)

### Getting started ###

#### 0. Prerequisites####
This package is designed to work with certain types of projects. Your project should be using and have configured
* Iron Router - `meteor add  iron:router`
* Collection Helpers - `meteor add dburles:collection-helpers`
* Collection2 - `meteor add aldeed:collection2`
* An accounts system - e.g. `meteor add accounts-base accounts-password`
* Roles - `meteor add alanning:roles`
* Bootstrap 3 - e.g. `meteor add twbs:bootstrap`
* Fontawesome - e.g. `meteor add fortawesome:fontawesome`

#### 1. Install ####
Download to your packages directory and run `meteor add yogiben:admin` then go to `/admin` for the setup wizzard.

#### 2. Config ####
The simplest possible config with one, 'Posts', collection.

#####Server and Client#####
```javascript
AdminConfig = {
  collections: {
    Posts: {}
  }
};
```
This config will make the **first user** admin.

You can also set the adminEmails property which will will override this.
```javascript
AdminConfig = {
  name: 'My App'
  adminEmails: ['ben@code2create.com']
  collections: {
    Posts: {}
  }
};
```
#### 3. Define your data models ####
If you are unfamiliar with [autoform](https://github.com/aldeed/meteor-autoform) or [collection2](https://github.com/aldeed/meteor-collection2) or [collection-helpers](https://github.com/dburles/meteor-collection-helpers) you should check them out now.

You need to define and attach a schema to the collections that you want to edit via the admin dashboard. Check out the [documentation](https://github.com/aldeed/meteor-collection2).
```
@Schemas = {}

@Posts = new Meteor.Collection('posts');

Schemas.Posts = new SimpleSchema
	title:
		type: String
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
@AdminConfig =
    nonAdminRedirectRoute: 'entrySignIn',
    collections:
        Posts: {
            icon: 'pencil'
            tableColumns: [
              {label: 'Title', name: 'title'}
	            {label: 'Published', name: 'published'}
	            {label: 'User', name: 'owner', template: 'userEmail'}
            ]
            templates:
              new:
                name: 'postWYSIGEditor'
                data:
                  post: Session.get 'admin_doc' if Meteor.isClient
              edit:
                name: 'postWYSIGEditor'
                data:
                  post: ()-> Session.get 'admin_doc' if Meteor.isClient
            selector: (userId)->
              return {ownerId: userId}
        },
        Comments: {
            icon: 'comment'
            omitFields: ['owner']
            tableColumns: [
              {label: 'Content', name: 'content'}
              {label: 'Post', name: 'postTitle()'}
              {label: 'User', name: 'owner', template: 'userEmail'}
            ]
            showWidget: false
        }
    autoForm:
        omitFields: ['createdAt', 'updatedAt']
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

Comments.helpers({
  postTitle: function () {
    if (this.post) {
      return Posts.findOne(this.post).title;
    }
  }
});

Posts.attachSchema(Schemas.Posts)
```

#### Collections ####
`AdminConfig.collections` tells the dashboard which collections to manage based on the global variable name.
```javascript
AdminConfig = {
  collections: {
    Posts: {
      // collection options
    },
    Comments: {
      // collection options
    }
  }
};
```
It is possible to configure the way the collection is managed.
```
Comments: {
  icon: 'comment'
  omitFields: ['updatedAt']
  tableColumns: [
   { label: 'Content', name: 'content' },
   { label: 'Post', name: 'postTitle()' },
   { label: 'User', name: 'owner', template: 'userEmail' }
  ]
  showEditColumn: true // Set to false to hide the edit button. True by default.
  showDelColumn: true // Set to false to hide the edit button. True by default.
  showWidget: false
  color: 'red'
}
```

##### Collection options #####
`icon` is the icon code from [Font Awesome](http://fortawesome.github.io/Font-Awesome/icons/).

`tableColumns` an array of objects that describe the columns that will appear in the admin dashboard.

* `{label: 'Content', name:'content'}` will display the `content` property of the mongo doc.
* `{label: 'Post', name: 'postTitle()'}` will use `postTitle` collection helper (see `dburles:collection-helpers` package).
* `{label: 'Joined', name: 'createdAt', template: 'prettyDate'}` will display `createdAt` field using `prettyDate` template. Following object will be set as the context:
```
{
  value: // current cell value
  doc:   // current document
}
```

`fields` is an array of field names - set when the form should only show these fields. From [AutoForm](https://github.com/aldeed/meteor-autoform).

`extraFields` fields to be subscribed but not displayed in the table. Can be used if collection helper depends on the field which is not in the table.

`omitFields` hides fields that we don't want appearing in the add / edit screens like 'updatedAt' for example. From [AutoForm](https://github.com/aldeed/meteor-autoform).

`showWidget` when set to false hides the corresponding widget from the dashboard.

`color` styles the widget. See the [LTE Admin documentation](https://almsaeedstudio.com/preview).

#### Users ####

The Meteor.users collection is automatically added to the admin panel.
You can create, view and delete users.

If you have attached a schema to the user, it will automatically be used for the edit form.
You can disable this functionality, or customize the schema that is used.

```javascript
AdminConfig = {
  //...

  // Disable editing of user fields:
  userSchema: null,

  // Use a custom SimpleSchema:
  userSchema: new SimpleSchema({
    'profile.gender': {
       type: String,
       allowedValues: ['male', 'female']
     }
  })
}
```

#### Custom Templates ####
The default admin templates are autoForm instances based on the schemas assigned to the collections. If they don't do the job, you specify a custom template to use for each of the `new`,`edit` and `view` screens for each collection.
```javascript
AdminConfig = {
  // ...
  collections: {
    Posts: {
      templates: {
        new: {
          name: 'postWYSIGEditor'
        },
        edit: {
          name: 'postWYSIGEditor',
          data: {
             post: Meteor.isClient && Session.get('admin_doc')
          }
        }
      }
    }
  }
};
```
The `/admin/Posts/new` and `/admin/Posts/edit` will now use the `postWYSIGEditor` template that you've defined somewhere in your code. The `edit` view will be rendered with a data context (here the document being edited).

Custom templates are most used when you need to use an {{#autoForm}} instead of the default {{> quickForm}}.

#### Custom route options ####
It is possible to setup some custom options that will be used during the
generation of the routes for your collections. If no options are given, default
ones will be used.

This could be useful in order to set up `waitOn` or `onAfterAction` hooks:

```javascript
AdminConfig = {
  // ...
  collections: {
    Posts: {
      routes: {
        new: {
          waitOn: function () { return Meteor.subscribe('images'); }
        },
        view: {
          waitOn: function () { return Meteor.subscribe('images'); }
        },
        edit: {
          waitOn: function () { return Meteor.subscribe('images'); }
        }
      }
    }
  }
  // ...
}
```

All the options that Iron Router accept are also accepted here, except:
`path`, `template`, `controller`, `action` and `data`.

However, `data` context could be set up using the `collectionObject` key:
```javascript
AdminConfig = {
  // ...
  collections: {
    Posts: {
      collectionObject: {
        key: 'value'
      }
    }
  }
  // ...
}
```

#### Autoform ####
```javascript
AdminConfig = {
  // ...
  autoForm:
    omitFields: ['createdAt', 'updatedAt']
};
```
Here you can specify globally the fields that should never appear in your `new` and `update` views. This is typically meta information likes dates.

**Important** don't omit fields unless the schema specifies either an `autoValue` or `optional` is set to `true`. See [autoForm](https://github.com/aldeed/meteor-autoform).

#### AdminLTE Skin ####
In order to customise the skin, add the key `skin` with one of the allowed values. `skin` defaults to `"blue"`.

Available skins: `black black-light blue blue-light green green-light purple purple-light red red-light yellow yellow-light`

```javascript
AdminConfig = {
  // ...
  skin: 'black-light',
  // ...
}
```

#### Dashboard ####
Here you can customise the look and feel of the dashboard.
```javascript
AdminConfig = {
  // ...
  dashboard: {
    homeUrl: '/dashboard',
    widgets: [
      {
        template: 'adminCollectionWidget',
        data: {
          collection: 'Posts',
          class: 'col-lg-3 col-xs-6'
        }
      },
      {
        template: 'adminUserWidget',
        data: {
          class: 'col-lg-3 col-xs-6'
        }
      }
    ]
  }
};
```
`homeUrl` is the `href` property of the 'Home' button. Defaults to `/`.

`widgets` is an array of objects specifying template names and data contexts. Make sure to specify the `class` in the data context. If set, the `widgets` property will override the collection widgets which appear by default.

#### Extending Dashboard ####
There are few things you can do to integrate your package with meteor-admin. Remember to wrap it in Meteor.startup on client.

#####Create custom path to admin dashboard#####

```javascript
AdminDashboard.path('/:collection/delete')
```

Note: you can omit the leading slash (it will be inserted automatically).

#####Add sidebar item with single link#####

```javascript
AdminDashboard.addSidebarItem('New User', AdminDashboard.path('/Users/new'), { icon: 'plus' })
```

#####Add sidebar item with multiple links#####

```javascript
AdminDashboard.addSidebarItem('Analytics', {
  icon: 'line-chart',
  urls: [
    { title: 'Statistics', url: AdminDashboard.path('/analytics/statistics') },
    { title: 'Settings', url: AdminDashboard.path('/analytics/settings') }
  ]
});
```

#####Add link to collection item#####

This will iterate through all collection items in sidebar and call your function. If you return an object with the `title` and `url` properties the link will be added. Otherwise it will be ignored.

```javascript
AdminDashboard.addCollectionItem(function (collection, path) {
  if (collection === 'Users') {
    return {
      title: 'Delete',
      url: path + '/delete'
    };
  }
});
```

#####Add custom route#####

If you want to add your own sub route of admin dashboard (using iron:router package) there are three key things to follow

1) Use `AdminDashboard.path` to get the path

2) Use `AdminController`

3) Set `admin_title` (and optionally `admin_subtitle`) session variable

e.g.

```javascript
Router.route('analytics', {
  path: AdminDashboard.path('analytics'),
  controller: 'AdminController',
  onAfterAction: function () {
    Session.set('admin_title', 'Analytics');
  }
});
```

#### Logout Redirects ####

If you want to redirect to a custom route after the user is loggged out, you can use the `logoutRedirect` setting.

```javascript
AdminConfig = {
  logoutRedirect: 'login' // Redirect to the route named 'login' after logging out.
}
```

### Premium Support ###
Have an urgent issue or want help with implementation? Start a conversation with [Meteor Factory](http://meteorfactory.io).
