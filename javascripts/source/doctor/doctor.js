
//Fires submit on replaced submit buttons
$( document ).ready(function() {
	$( ".contactFormBtn" ).on('click', function(e) {
		$('#contactForm').trigger('submit');
	});

});

//changeTab
//Changes a tab content
function changeTab(type, tabName){
	console.log('Changing Doctor Tab '+tabName);
	var url = '/doctor/tabs/'+type+'/'+tabName;
	var loadingImg = '<div class="loading-spinner mainTabLoadingImg"></div>';
	$('#content').html(loadingImg);

	$.get(url, function(data){
		$('#content').toggle();
		$('#contentContainer ul li.blueBtn').removeClass("blueBtn");
		$('#'+tabName+'Tab').addClass("blueBtn");
		$('#content').html(data);
		$('#content').fadeIn();
	});
}

function showBulkMedContent(content){
		$('.bulkMedItemActiveContent').toggle();
		$('.bulkMedItemActiveContent').removeClass("bulkMedItemActiveContent");
		$('.subTabSelected').removeClass("subTabSelected");
		$('.bulkMedItemContent'+content).toggle();
		$('.bulkMedItemContent'+content).addClass("bulkMedItemActiveContent");
		$('#bulkContentTab'+content).addClass("subTabSelected");
}

function updateBulkQtyCount(){
	var qty = 0;
	$('.itemQtySelect').each(function(){
		qty = qty + parseInt(this.value);
	});
	$('#bulkItemQty').text(qty);
}

function updateBulkPtCount(){
	var qty = 0;
	$('.ptRow').each(function(){
		qty++;
	});
	$('#bulkPtQty').text(qty);
}

// showCreateRx
// Show Create Prescription popup
function showCreateRx(){
	console.log('Showing Create Rx popup');
	var url = '/createRx';
	$.get(url, function(data){

		// If Dialog is already visible, we need to close to make sure background is correct
		// if($('#dialog').is(":visible")){
		// 	closeDialog();
		// }



		// Open Dialog
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
		// load html
		$('#dialog').html(data);
		$('#dialog').css('background', '#e8e9ea');
		$('#dialog').css('width', '950px');


	});
}


// createRxPatient
// Show Create Prescription Popup, populated with patient info
function createRxPatient(){
	var $form = $('#createRxChoosePatient');
	var name = $form.find( "input[name='name']" ).val();
	var phone = $form.find( "input[name='phone']" ).val();
	var url = '/createRX?&name='+name+'&phone='+phone;
	$.get(url, function(data){
		$('#dialog').dialog({
			modal: true,
			height: 'auto',
			width:950,
			top:20,
			position: {
				my: "center top",
				at: "center top",
				of: window
			}
		});
		$('#dialog').css('background', 'transparent');
		$('#dialog').css('overflow', 'auto');
		$('#dialog').css('width', '950px');
		$('#dialog').html(data);
	});
}



// showRxMedContent
// Show Medications by Type in Create Patient Rx Window
function showRxMedContent(type){
	console.log('Showing '+type);

	var url = '/createRx/'+type;
	// If Showing Compounds

	$.get(url, function(data){

		if(!$('#medBrowseContainer').is(':visible')){
			$('#medBrowseContainer').toggle();
		}
		if($('#createRxTableContainer').is(':visible')){
			$('#createRxTableContainer').toggle();
		}
		$('#medBrowseContainer').html(data);
	});

}


// showRxMedInfo
// Show Medication info in create Prescription Content Pane
function showRxMedInfo(type, id){
	var url = '/createRx/'+type+'/info/'+id;
	$.get(url, function(data){
		$('#medBrowseContainer').html(data);
	})
}



// showCurrentRx
// Hides current content pane in createRx popup
// and shows the current items in the prescription
function showCurrentRx(){
	$('#medBrowseContainer').toggle();
	$('#createRxTableContainer').toggle();
}

// openCategory
// Changes display content in create rx panel to specified category
function openCategory(type, id){
	var url = '/createRx/'+type+'/'+id;
	$.get(url, function(data){
		$('#medBrowseContainer').html(data);
	})

}

// toggleCurrentRxContents
// Displays current prescription contents if not visible, destroying ajax contents
// if is visible, hides
function toggleCurrentRxContents(){
	if($('#createRxTableContainer').is(':visible')){
		$('#createRxTableContainer').toggle();
		$('#medBrowseContainer').toggle();
	}
	else{
		$('#medBrowseContainer').html('');
		if($('#medBrowseContainer').is(':visible')){
			$('#medBrowseContainer').toggle();
		}
		$('#createRxTableContainer').toggle();
	}
}


// showRxCustomContact
// Loads custom compound inquriy contact form into create Rx form
function showRxCustomContact(){

	var url = '/doctor/customCompoundInquiry';

	$.get(url, function(data){
		var contactDiv = '<div id="createRxCompInquiryCont" class="createRxContentItem">'+data+'</div>';
		$('#createRxSelectedPatientCnt').append(contactDiv);
	});
}


// addToRx
// Adds item to current Rx
function addToRx(type, id){

	// Get row number for this item
	var item = parseInt($('#createRxNumItems').val()) + 1;

	var url = '/createRx/add/'+type+'/'+id+'/?item='+item;

	$.get(url, function(data){
		// Hide Empty Row
		$('#emptyRxRow').css('display', 'none');

		// Add Item to Rx Table
		$('#createRxTableContainer table tbody').append(data);

		// Update Number of Items
		$('#createRxNumItems').val(item);

		// Show Rx Table
		showCurrentRx();
	})

}

// Show Create patient popup
function showCreatePatient(){
	console.log('Showing Create Patient popup');
	var url = '/createPatient';
	$.get(url, function(data){
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
		$('#dialog').html(data);
		$('#dialog').css('background', '#e8e9ea');

	});
}

// Show Contact Popup
function showContactAmex(){
	console.log('Showing Contact popup');
	var url = '/doctor/contact';
	$.get(url, function(data){
		$('#dialog').dialog({
			modal:true,
			height:'auto',
			width:950,
			top:20,
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

// Show Create New Authorized User Popup
function showNewAuthorizedUser(){
	var url = '/doctor/addAuthorizedUser';
	$.get(url, function(data){
		$('#dialog').dialog({
			modal:true,
			height:'auto',
			width:950,
			top:20,
			position: {
				my: "center top",
				at: "center top",
				of: window
			}
		});
		$('#dialog').html(data);
	});
}


// showRxCreator
// Shows Create Rx Table Template in Dialog
function showRxCreator(){
	var url = '/createRx/creator';

	var formData = {

	}


	$.get(url, function(data){
		$('#dialog').dialog({
			modal:true,
			height:'auto',
			width:950,
			top:20,
			position: {
				my: "center top",
				at: "center top",
				of: window
			}
		});
		$('#dialog').html(data);
	});
}


// showRxAuthorize
// Shows Authorize RX template in Dialog
function showRxAuthorize(prescription){
	var src = "/prescriptions/authorize/";
	var formData = {prescriptionID: prescription}
	var loadingImg = '<div id="authLoadingContainer"><div id="rxAuthLoadingImg" class="loading-spinner mainTabLoadingImg"></div><span>Loading..</span></div>';
	$('#dialog').html(loadingImg);
	$('#dialog').dialog({
		modal:true,
		height:'auto',
		width:950,
		top:20,
		position: {
			my: "center top",
			at: "center top",
			of: window
		}
	});

	   //var iframe = $('<iframe name="authForm" id="authFrame" src="'+src+'" frameborder="0" marginwidth="0" marginheight="0" height="800" style="overflow:hidden" width="800" allowfullscreen></iframe>');
	  // var form = '<form id="authRenderForm" method="post" action="'+src+'" target="authFrame"><input type="hidden" name="prescriptionID" value="'+prescription+'" /></form>'

	  $.post(src, formData, function(data){
	  	$('#dialog').html('');
	  	$('#dialog').html(data);


	  });


	}

// search
// submits top search page form
	function search(){

		$('#searchForm').submit();
	}


// sendToCreator
// shows Prescription Creator [Step 2] in Dialog Window
function sendToCreator(){
	var url = '/createRx/creator';
	var $billSelect = $('#createRxBillingSelect');
	var $shipSelect = $('#createRxShippingSelect');
	var $patient =  $('#createRxInput1');

	// Create Struct to send to creation page
	var formData = {}
	formData[$billSelect.attr('name')] = $billSelect.val();
	formData[$shipSelect.attr('name')] = $shipSelect.val();
	formData[$patient.attr('name')] = $patient.val();

	// Load Creation page in dialog with form data
	$.post(url, formData, function(data){
		console.log(formData);
		$('.activeRxStep').removeClass("activeRxStep");
		$('.activeStepText').removeClass("activeStepText");
		$('.activeStep').removeClass("activeStep");
		$('#selectMedicationStep').addClass("activeRxStep");
		$('#selectMedicationStep .stepNumber').addClass("activeStep");
		$('#selectMedicationStep .stepText').addClass("activeStepText");
		$('#createRxStepContentContainer').html(data);
	});
}


//createNewRx
//Submits Create Prescription Form
function createNewRx(){
	console.log('Submiting Rx');
	var testString = $("#createNewRxForm").serialize();
	var url = '/createRx/process/';
	var testUrl = url + testString;

	console.log(testUrl);

	// serialize form to object
	var formData = {};
	$("#createMedForm").serializeArray().map(function(x){formData[x.name] = x.value;});
	console.log(formData);

	var loadingImg = '<div id="authLoadingContainer"><div id="rxAuthLoadingImg" class="loading-spinner mainTabLoadingImg"></div><span>Loading..</span></div>';
	$('#createRxStepContentContainer').html(loadingImg);

	// submit
	$.post(url, formData, function(data){
		console.log(formData);
		$('.activeRxStep').removeClass("activeRxStep");
		$('.activeStepText').removeClass("activeStepText");
		$('.activeStep').removeClass("activeStep");
		$('#authorizedStep').addClass("activeRxStep");
		$('#authorizedStep .stepNumber').addClass("activeStep");
		$('#authorizedStep .stepText').addClass("activeStepText");

		// If We have success code, show auth
		var status = $.parseJSON( data );
		console.log(data);

		if(status['RESPONSECODE'] === 200){
			showAuthorization(status['PRESCRIPTION']);
		}
		else{
			$('#rxInfoContainer').html(data);
		}

	});
}

// showAuthorization
// Shows Authorization Step 3 in Dialog Window
function showAuthorization(prescription){
	var src = "/createRx/authorize/";
	var formData = {prescription: prescription}
	var loadingImg = '<div id="authLoadingContainer"><div id="rxAuthLoadingImg" class="loading-spinner mainTabLoadingImg"></div><span>Loading..</span></div>';
if($('#createRxStepContentContainer').length){
	formData.view = 'step';
	$('#createRxStepContentContainer').html(loadingImg);
		console.log(prescription);
}
else{
	formData.view = 'full';
	$('#dialog').dialog({
			modal:true,
			height:'auto',
			width:950,
			top:20,
			position: {
				my: "center top",
				at: "center top",
				of: window
			}
		});
	$('#dialog').html(loadingImg);
	console.log(prescription);
}



console.log(formData);

	$.post(src, formData, function(data){
		if(formData.view === 'full'){

		$('#dialog').html(data);
		}
		else{
	  	$('#createRxStepContentContainer').html(data);
	  }
	 });
}

// submitQuestion
// submits contact popup form
function submitQuestion(){


}




// closeIFrame
// Global Variable so its accessible from inside an Iframe
var closeIFrame = function() {
	$('#dialog').html('');
	closeDialog();
}


var resizeAuthFrame = function(height, width){
	$('#authFrame').height(height);
	$('#authFrame').width(width);
}

var moveDialogFromTop = function(top){
	$('#dialog').css('top', top);
}

var changeDialogContent = function(content){
	$('#dialog').html(content);
}


//validate Security Input
function validateSecurityInput(){
	var url = '/processSignature/';
	// construct signature data
	var formData = {};
	$("#securityCodeForm").serializeArray().map(function(x){formData[x.name] = x.value;});
	console.log(formData);
	var loadingImg = '<div id="signatureLoadingContainer"><div id="rxAuthLoadingImg" class="loading-spinner mainTabLoadingImg"></div><span>Validating Security Credentials</span></div>';
	$('#rxSecurityCodeContainer').html(loadingImg);
	// send container signature for processing
	$.post(url, formData, function(data){
		$('#createRxStepContentContainer').html(data);
	});

}
// close dialog box when clicking the darkened outside
$('body').on('click','.ui-widget-overlay',function(){
	$('#dialog').dialog('close');
	$('#createRxStepContentContainer').remove()
});


//temp erase after shipping is populated
$("#pic").click(function () {
	if( $(this).attr("src") == "images/ship2.png"){
   $(this).attr("src","images/shipping1.png")

} else{
   $(this).attr("src","images/ship2.png")
}
})



// Submit Bulk Form
function submitBulkPatientForm(){
	$('#bulkOrderForm').submit();
}


// Bulk Prescribe Functions
function showMedItemPatients(){


}
