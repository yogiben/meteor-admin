Package.describe({
  name: "yogiben:admin",
  summary: "A complete admin dashboard solution",
  version: "1.1.0",
  git: "https://github.com/yogiben/meteor-admin"
});

Package.on_use(function(api){

  both = ['client','server']

  api.versionsFrom('METEOR@1.0');

  api.use(
    ['iron:router@1.0.7',
    'coffeescript',
    'underscore',
    'aldeed:collection2@2.3.2',
    'aldeed:autoform@4.2.2 || 5.0.0',
    'aldeed:template-extension@3.1.1',
    'alanning:roles@1.2.13',
    'raix:handlebar-helpers@0.2.4',
    'reywood:publish-composite@1.3.5',
    'momentjs:moment@2.9.0',
    'aldeed:tabular@1.0.6',
    'meteorhacks:unblock@1.1.0'
    ],
    both);

  api.use(['less','session','jquery','templating'],'client')

  api.use(['email'],'server')

  api.add_files([
    'lib/both/AdminDashboard.coffee',
    'lib/both/router.coffee',
    'lib/both/utils.coffee',
    'lib/both/startup.coffee',
    'lib/both/collections.coffee'
    ], both);

  api.add_files([
    'lib/client/html/admin_templates.html',
    'lib/client/html/admin_widgets.html',
    'lib/client/html/admin_layouts.html',
    'lib/client/html/admin_sidebar.html',
    'lib/client/html/admin_header.html',
    'lib/client/css/admin-layout.less',
    'lib/client/css/admin-custom.less',
    'lib/client/js/admin_layout.js',
    'lib/client/js/helpers.coffee',
    'lib/client/js/templates.coffee',
    'lib/client/js/events.coffee',
    'lib/client/js/slim_scroll.js',
    'lib/client/js/autoForm.coffee',
    ], 'client');

  api.add_files([
    'lib/server/publish.coffee',
    'lib/server/methods.coffee'
    ], 'server');



  api.export('AdminDashboard',both)

});
