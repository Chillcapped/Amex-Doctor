

<!---
<cfdump var="#prescriptionID#">
<cfdump var="#errors#">
<cfdump var="#params#">
	<cfdump var="#form['#hash('securityCode')#']#" label="Security Code">
		<cfdump var="#form['#hash('imageData')#']#" label="Signature Image">
		<cfdump var="#form['#hash('pad')#']#" label="Pad Number">
		<cfdump var="#form['#hash('rx')#']#" label="Rx Number">
		<cfdump var="#form['#hash('securityToken')#']#" label="Security Token">
--->
<div id="processSignatureContainer">
	<cfif signaturePadData.valid>
		<h4>Successfully Authorized Prescription</h4>
		<p>Your prescription has been sent to our pharmacy and will be processed shortly.</p>
	<cfelse>	
		<h4>Signature Request not Valid</h4>
	</cfif>
	
	<!--- Show Completed PDF IN Iframe --->
	<div id="successRxPDFContainer">
		
	</div>

	<div id="processSignatureBtmBtns">
		<ul>
			<a href="javascript:closeDialog();"><li class="blueButton">Close</li></a>
		</ul>	
	</div>
</div>

<!---
<cfdump var="#form#">
<cfdump var="#signaturePadData#">
--->

