// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function() {
  var faye = new Faye.Client('http://localhost:9292/faye');
  faye.subscribe('/messages/new', function (data) {
    $('#chat_box').append($('</div>').text(data));
  });
  
  $('#message_submit').click(function(e) {
    client.publish('/messages/new', {text: $('#message_text')});
  });
  
});