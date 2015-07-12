

// showPatientInfo
// Shows Patient info in modal window
function showPatientInfo(pt){
	var url = '/patients/information/'; 
	
	var formData = {
			patient: pt
	}
	
	$.post(url, formData, function(data){
		$('#dialog').dialog({
			modal:true,
			width:950,
			height:'auto',
			top:20,
			position: {
				my: "center top", 
				at: "center top", 
				of: window 
			}
		});
		$('#dialog').css('background', '#e8e9ea');
	    $('#dialog').html(data);
	});
}


// changePatientInfoContent
// Changes Content Pane
function changePatientInfoContent(content, patient){
	
	console.log('Changing Patient Info Tab to '+content);
	
	if(content === 'profile'){
		showPatientInfo(patient);
	}
	else if(content === 'notes'){
		var url = '/patients/notes/'+patient; 
		$.get(url, function(data){
			$('#dialog').dialog({
				modal:true,
				height:860,
				width:800,
				top:20
			});
			$('#dialog').css('background', '#e8e9ea');
		    $('#patInfoFullContainer').html(data);
		});
	}
	else if(content === 'history'){
		var url = '/patients/history/'+patient; 
		$.get(url, function(data){
			$('#dialog').dialog({
				modal:true,
				height:860,
				width:800,
				top:20
			});
			$('#dialog').css('background', '#e8e9ea');
		    $('#patInfoFullContainer').html(data);
		});
	}
}


function togglePatientCardUpload(){
	
}


// savePatientProfileInfo
// Submits Patient Profile Update Form in Profile Popup
function savePatientProfileInfo(){
	console.log('Submiting Patient Info');
	var testString = $("#patientInfoForm").serialize();
	
	
	console.log(testString);
	
	// serialize form to object
	var formData = {};
	$("#patientInfoForm").serializeArray().map(function(x){formData[x.name] = x.value;}); 
	
	console.log(formData);
	
	$('#patientInfoForm').submit();
	
}

// createPatientRx2
function createPatientRx(patient){
	var url = '/patients/createRX/'+patient;
	console.log(url);
	$.get(url, function(data){
		$('#dialog').css('background', 'transparent');
		$('#dialog').css('overflow', 'auto');
		$('#dialog').css('width', '945px');
	    $('#dialog').html(data);
		
	});
}


// submitNewPatient
// Submites create patient form
function submitNewPatient(){
	$('#formSubmission').submit();
}

