<!--- Create RX Popup Form --->

<div id="createRxContainer">
	<!--- If we have a patient ID, show patient Form --->
	<cfif structKeyExists(variables, "patientInfo")>
		<cfinclude template="form.cfm">
	<!--- If we dont have a patient ID, show patient lookup --->
	<cfelse>
		<cfinclude template="choosePatient.cfm">
	</cfif>
</div>
