Template.AdminLayout.created = function () {
  var self = this;

  self.minHeight = new ReactiveVar(
    $(window).height() - $('.main-header').height());

  $(window).resize(function () {
    self.minHeight.set($(window).height() - $('.main-header').height());
  });

  $('body').addClass('fixed');
};

Template.AdminLayout.destroyed = function () {
  $('body').removeClass('fixed');
};

Template.AdminLayout.helpers({
  minHeight: function () {
    return Template.instance().minHeight.get() + 'px'
  }
});

dataTableOptions = {
    "aaSorting": [],
    "bPaginate": true,
    "bLengthChange": false,
    "bFilter": true,
    "bSort": true,
    "bInfo": true,
    "bAutoWidth": false
};
