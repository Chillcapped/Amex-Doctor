 <!---- Doctor Signature Pad --->
	 <div id="signature-pad" class="m-signature-pad">
	    <div class="m-signature-pad--body">
	      <canvas id="canvas"/>
	    </div>
		
	    <div class="m-signature-pad--footer">
	      <div class="description">
	      	<cfoutput>
			 <ul>
			 	<li><span>IP: #request.cgi.remote_addr#</span></li>
				<li><span>eSignaturePadID: #signaturePadData.uniqueSignatureKey#</span></li>
			 </ul>
	       </cfoutput>
	      </div>
	      <button class="button clear" data-action="clear">Clear</button>
	      <button class="button save" data-action="save">Sign Prescription</button>
	    </div>
	  </div>
		
	 <div id="signatureFormContainer">
	  	<cfoutput>
		  	<canvas id="signaturePadIDCanvas"/>
			<canvas id="prescriptionCanvas"/>
  			<input type="hidden" name="#hash('signaturePad')#" id="signaturePadID" value="#signaturePadData.uniqueSignatureKey#">
			<input type="hidden" name="#hash('securityToken')#" id="securityToken" value="#signaturePadData.eSignatureKeyBase#">
			<canvas id="finalizedCanvas"/>
		</cfoutput>
	  </div>	

	  
	  
	 <!--- Jquery is Included because this is loaded in an Iframe ---> 
 <script type="text/javascript" src="/bower_components/jquery/jquery.min.js"></script>
	
 <script src="/bower_components/signature_pad/signature_pad.js"></script>
 		
 <script>
 	var preRenderedText = $('#signaturePadID').val();
	var prescriptionRenderedText = $('#prescription').val();
	var canvas = document.getElementById('canvas');
	var ctx = canvas.getContext('2d');
	ctx.font = 'bold 15px Courier';
	
	// Trick from http://stackoverflow.com/questions/2635814/
	

	var wrapper = document.getElementById("signature-pad"),
    clearButton = wrapper.querySelector("[data-action=clear]"),
    saveButton = wrapper.querySelector("[data-action=save]"),
    canvas = wrapper.querySelector("canvas"),
    signaturePad;
	
	// Adjust canvas coordinate space taking into account pixel ratio,
	// to make it look crisp on mobile devices.
	// This also causes canvas to be cleared.
	function resizeCanvas() {
	    var ratio =  window.devicePixelRatio || 1;
	    canvas.width = canvas.offsetWidth * ratio;
	    canvas.height = canvas.offsetHeight * ratio;
	    canvas.getContext("2d").scale(ratio, ratio);
		console.log(ratio);
	}
	
	window.onresize = resizeCanvas;
	resizeCanvas();
	
	signaturePad = new SignaturePad(canvas);
	
	
	// Clear Signature Pad
	clearButton.addEventListener("click", function (event) {
	    signaturePad.clear();
	});
	
	
	// On Save
	saveButton.addEventListener("click", function (event) {
	
	    if (signaturePad.isEmpty()) {
	        alert("Please provide signature first.");
	    } 
		else {
			// Create New Canvas to Transfer the Signature and Create "Layers" for ID Tokens
			var oldCanvas = canvas.toDataURL();
			var newCanvas = document.createElement('canvas');
			newCanvas.height = 200;
			newCanvas.width = 800;
			
			var img = new Image();
			img.src = oldCanvas;
			img.onload = function (){
				ctx = newCanvas.getContext('2d');
				ctx.font = 'bold 15px Courier';
				ctx.globalCompositeOperation='destination-over';
			    ctx.drawImage(img, 0, 0);
				ctx.font = 'Bold Italic 15px Courier';
				ctx.fillStyle = '#862028';
		    	ctx.textBaseline = 'top';
				ctx.fillText('SignatureID: '+preRenderedText,0, 165);
				ctx.fillText('PrescriptionID: '+prescriptionRenderedText,0, 180);
				
				// Create Signature Struct to Send 
		        var signatureData = {
					image: newCanvas.toDataURL(),
					pad: document.getElementById('signaturePadID').value,
					rx: window.parent.document.getElementById('prescription').value,
					securityToken: document.getElementById('securityToken').value
				}
				
				// Show Security Code popup 
				showSecurityCodePrompt(signatureData);
				
			};
		}
	});
	
	//
	function showSecurityCodePrompt(signatureData){
		var url = '/securityCodePrompt/';
		$.post(url, signatureData, function(data){
			window.parent.$('#createRxStepContentContainer').html(data);
		});
	}
	
	
	
</script>