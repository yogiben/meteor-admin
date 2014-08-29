Package.describe({
  name: "admin",
  summary: "A complete admin dashboard solution"
});

Package.on_use(function(api){

  both = ['client','server']

  api.use(
    ['iron-router',
    'coffeescript',
    'accounts-base',
    'templating',
    'underscore',
    'simple-schema',
    'roles'
    ],
    both);

  api.use(['less','session','autoform','jquery'],'client')

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
