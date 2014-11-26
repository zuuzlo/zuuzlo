$(document).ajaxComplete (event, request) ->
  msg = request.getResponseHeader("X-Message")
  alert_type = 'alert-success'
  alert_type = 'alert-danger' unless request.getResponseHeader("X-Message-Type").indexOf("danger") is -1
 
  unless request.getResponseHeader("X-Message-Type").indexOf("keep") is 0
    #add flash message if there is any text to display
    $("#flash_hook").replaceWith("<div id='flash_hook'>
          <div class='container'>
            <div class='row'>
                <div class='alert " + alert_type + "'>
                  <button type='button' class='close' data-dismiss='alert'>&times;</button>
                  " + msg + "
                </div>
              </div>
            </div>
          </div>") if msg
    #delete the flash message (if it was there before) when an ajax request returns no flash message
    $("#flash_hook").replaceWith("<div id='flash_hook'></div>") unless msg