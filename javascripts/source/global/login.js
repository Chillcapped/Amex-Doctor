function closeDialog(){
	$('#dialog').dialog("close");
}

$( document ).ready(function() {
	$( ".loginBtnDiv2" ).on('click', function(e) {
		$('#loginForm').trigger('submit');

	});

});


