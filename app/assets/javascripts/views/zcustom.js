 $(function(){
  $('.modal').on('shown', function () {
    $('#notify_receiver').change(function() {
      var notify_receiver = $('#notify_receiver').val()
      if(notify_receiver ==  'buyer'){
        html = '<option value="sms">短信</option>' 
      } 
      else{
        html = '<option value="Email">Email</option><option value="sms">短信</option>' 
      }
      $('#notify_type').html(html);
    })
  });
});