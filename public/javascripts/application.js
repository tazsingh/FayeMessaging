// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function() {
  var faye = new Faye.Client('http://192.168.1.149:9292/faye');
  faye.subscribe('/messages/new', function (data) {
    $('#chat_box').append($("<p>" + data + "</p>"));
  });
  
  $('#message_submit').click(function(e) {
    e.preventDefault();
    faye.publish('/messages/new', {text: $('#message_text')});
    return false;
  });
  
}); 