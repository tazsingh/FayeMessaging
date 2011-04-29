// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


$(function() {
  var chat_history = [];
  var current_value = '';
  var current_position = 0;
  
  var faye = new Faye.Client('http://192.168.1.149:9292/faye');
  faye.subscribe('/messages/new', function (data) {
    $('#chat_box').append($('<div class="message"><div class="timestamp">' + data.timestamp + '</div><div class="username">' + data.username + '</div><div class="text">' + data.text + '</div></div>'));
    $('#chat_box').scrollTop(1000000);
  });
  
  $('#message_submit').click(function(e) {
    e.preventDefault();
    
    chat_history.unshift($('#message_text').val());
    current_value = '';
    current_position = 0;
    
    faye.publish('/messages/new', {
      username: $('#message_username').val(),
      timestamp: (new Date()).getTime(),
      text: $('#message_text').val()
    });
    $('#message_text').val("");
    return false;
  });
  
  // catch some arrows
  $('#message_text').keydown(function(e) {
    if(e.keyCode == 38) { // up arrow goes up in history
      if(current_position == 0) {
        current_value = $('#message_text').val();
      }
    
      current_position++;
    
      var history_value = chat_history[current_position];
      if(history_value) {
        $('#message_text').val(history_value);
      }
    }
  }
  
}); 