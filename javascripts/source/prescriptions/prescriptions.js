// showPrescriptionInfo
// 
function showPrescriptionInfo(prescription){
	var url = '/prescriptions/info/';
	var formData = {
		prescriptionID: prescription
	}
	$.post(url, formData, function(data){
		$('#dialog').dialog({
			modal:true,
			height:'auto',
			width:950,
			top:210,
			position: {
				my: "center top", 
				at: "center top", 
				of: window 
			}
		});
		$('#dialog').html(data);
		$('#dialog').css('background', '#e8e9ea');

	});
}


// changeRxInfoContent
function changeRxInfoContent(content, prescription){
	var url = '/prescriptions/'+content+'/'+prescription;
	$.get(url, function(data){
		$('#dialog').html(data);
	});
	
}