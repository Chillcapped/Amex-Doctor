function closeDialog(){
	$('#dialog').removeAttr( 'style' );
	$('#dialog').dialog("close");
}

var b = document.documentElement;
b.setAttribute('data-useragent',  navigator.userAgent);
b.setAttribute('data-platform', navigator.platform );

// IE 10 == Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)

// Using jQuery (but could use pure JS with cross-browser event handlers):
var idlePromptSeconds = 5;
var idleLogoutSeconds = 25;

$(function(){
  var idleTimer;
  function resetTimer(){
    clearTimeout(idleTimer);
    idleTimer = setTimeout(whenUserIdle,idlePromptSeconds*1000);
    extIdleTimer = setTimeout(whenUserExtIdle,idleLogoutSeconds*1000);
  }
  $(document.body).bind('mousemove,keydown,click',resetTimer);
  resetTimer(); // Start the timer when the page loads
});

// Prompt User to continue activity
function whenUserIdle(){
	console.log('Show Timout Continue')
  //...
}

// When User Def Idle
function whenUserExtIdle(){
	console.log('USer has been idle for ext timer, logging them out');

  //...
}
