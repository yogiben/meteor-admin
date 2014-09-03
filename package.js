Package.describe({
  summary: "A complete admin dashboard solution",
  version: "0.9.2",
  git: "https://github.com/yogiben/meteor-admin"
});

Package.on_use(function(api){

  both = ['client','server']

  api.use(
    ['iron:router@0.9.1',
    'coffeescript',
    'accounts-base',
    'accounts-password',
    'underscore',
    'aldeed:simple-schema@0.7.0',
    'aldeed:collection2@0.4.6',
    'alanning:roles@1.2.12',
    'raix:handlebar-helpers@0.1.2'
    ],
    both);

  api.use(['less','session','aldeed:autoform','jquery','templating'],'client')

  api.use(['email'],'server')

  api.add_files([
    'lib/both/AdminDashboard.coffee',
    'lib/both/router.coffee'
    ], both);
  
  api.add_files([
    'lib/client/html/admin_templates.html',
    'lib/client/html/admin_widgets.html',
    'lib/client/html/admin_layouts.html',
    'lib/client/html/admin_sidebar.html',
    'lib/client/html/admin_header.html',
    'lib/client/css/admin-layout.less',
    'lib/client/js/admin_layout.js',
    'lib/client/js/helpers.coffee',
    'lib/client/js/events.coffee',
    'lib/client/js/slim_scroll.js',
    'lib/client/js/datatable.js',
    'lib/client/js/autoForm.coffee',
    ], 'client');

  api.add_files([
    'lib/server/publish.coffee',
    'lib/server/methods.coffee'
    ], 'server');



  api.export('AdminDashboard',both)

});
