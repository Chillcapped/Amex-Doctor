<!--- Patient Info Popup Template --->



<cfif structKeyExists(variables, "patientInfo")>
	<div class="tabTopNav">
		<ul class="tabs">
			<cfoutput>
			<a href="javascript:changePatientInfoContent('profile');"><li>Patient Profile</li></a>
			<a href="javascript:changePatientInfoContent('history');"><li>Prescription History</li></a>
			<a href="javascript:changePatientInfoContent('notes');"><li>Patient Notes</li></a>
			<a href="javascript:createPatientRx('#patientINfo.patient.patientID#');"><li>Create Rx</li></a>
			</cfoutput>
		</ul>
	</div>
<div id="patientInfoPopContainer">

	
<div id="patInfoFullContainer">
	<div id="patInfoPopInformationContainer">
	<h4 style="width:50%; float:left;">Patient Profile: <cfoutput>#patientInfo.patient.firstName# #patientInfo.patient.middleName# #patientInfo.patient.lastName#</cfoutput></h4>
	<span id="patInfoPopLastUpdated"><cfoutput>#patientInfo.patient.lastUpdate#</cfoutput></span>
	<form action="/patients/update/" id="patientInfoForm">
	<div style="clear:both;"></div>
		<div class="thirds">
			<h4>General</h4>
		
		<cfoutput>
				
					<label>First: </label><input type="text" name="#application.formMask['firstName'].hash#" value="#patientInfo.patient.firstName#">
					<label>Middle:</label><input type="text" name="#application.formMask['middleName'].hash#" value="#patientInfo.patient.middleName#">
					<label>Last:</label><input type="text" name="#application.formMask['lastName'].hash#" value="#patientInfo.patient.lastName#">
					<label>DOB:</label><input type="text" name="#application.formMask['dob'].hash#" value="#patientInfo.patient.dob_full#">
					<label>SSN:</label><input type="text" name="#application.formMask['ssn'].hash#" value="#patientInfo.patient.ssn#">
		</cfoutput>
		</div>

	
	
		<div class="thirds">
			<h4> Shipping Addresses</h4>
				<cfif structKeyExists(patientInfo.patient, "primaryShipping")>
					
						<cfoutput>
						<label>Address 1</label> <input type="text" name="#application.formMask['shipAddress1'].hash#" placeholder="Address Line 1" value="#patientInfo.patient.address[patientInfo.patient.primaryShipping].address1#">
						<label>Address 2</label> <input type="text" name="#application.formMask['shipAddress2'].hash#" placeholder="Address Line 2" value="#patientInfo.patient.address[patientInfo.patient.primaryShipping].address2#">
						<label>City</label> <input type="text" name="#application.formMask['shipCity'].hash#" placeholder="City" value="#patientInfo.patient.address[patientInfo.patient.primaryShipping].city#">
						<label>State</label><input type="text" name="#application.formMask['shipState'].hash#"  placeholder="State" value="#patientInfo.patient.address[patientInfo.patient.primaryShipping].state#">
						<label>Zip</label><input type="text" name="#application.formMask['shipZip'].hash#"  placeholder="Zip" value="#patientInfo.patient.address[patientInfo.patient.primaryShipping].zip#">
						</cfoutput>
					
				<cfelse>
						
						<cfoutput>
						<label>Address 1</label><input type="text" name="#application.formMask['shipAddress1'].hash#" placeholder="Address Line 1" value="">
						<label>Address 2</label><input type="text" name="#application.formMask['shipAddress2'].hash#" placeholder="Address Line 2" value="">
						<label>City</label><input type="text" name="#application.formMask['shipCity'].hash#" placeholder="City" value="">
						<label>State</label><input type="text" name="#application.formMask['shipState'].hash#"  placeholder="State" value="">
						<label>Zip</label><input type="text" name="#application.formMask['shipZip'].hash#"  placeholder="Zip" value="">
						</cfoutput>
						
				</cfif>
		
		</div>
		
		<div class="thirds">
			<h4> Billing Addresses</h4>
			<cfif structKeyExists(patientInfo.patient, "primarybilling")>
				<cfoutput>
				
					<label>Address 1</label><input type="text" name="#application.formMask['billAddress1'].hash#" placeholder="Address Line 1" value="#patientInfo.patient.address[patientInfo.patient.primaryBilling].address1#" />
					<label>Address 2</label><input type="text" name="#application.formMask['billAddress2'].hash#" placeholder="Address Line 2"  value="#patientInfo.patient.address[patientInfo.patient.primaryBilling].address2#" />
					<label>City</label><input type="text" name="#application.formMask['billCity'].hash#" placeholder="City"  value="#patientInfo.patient.address[patientInfo.patient.primaryBilling].city#" />
					<label>State</label><input type="text" name="#application.formMask['billState'].hash#"  placeholder="State" value="#patientInfo.patient.address[patientInfo.patient.primaryBilling].state#" />
					<label>Zip</label><input type="text" name="#application.formMask['billZip'].hash#" placeholder="Zip"  value="#patientInfo.patient.address[patientInfo.patient.primaryBilling].zip#" />
					
				</cfoutput>
			<cfelse>
			
					<cfoutput>
					<label>Address 1</label><input type="text" name="#application.formMask['billAddress1'].hash#" placeholder="Address Line 1" value="" />
					<label>Address 2</label><input type="text" name="#application.formMask['billAddress2'].hash#" placeholder="Address Line 2"  value="" />
					<label>City</label><input type="text" name="#application.formMask['billCity'].hash#" placeholder="City"  value="" />
					<label>State</label><input type="text" name="#application.formMask['billState'].hash#"  placeholder="State" value="" />
					<label>Zip</label><input type="text" name="#application.formMask['billZip'].hash#" placeholder="Zip"  value="" />
					</cfoutput>
				
			</cfif>
		</div>
	<div style="clear:both;"></div>
		<div class="thirds">
			<h4>Contact Info:</h4>
					<cfoutput>
					<label>Email</label><input type="text" name="#application.formMask['email'].hash#" value="#patientInfo.patient.email#">
					<label>Home Phone</label><input type="text" name="#application.formMask['homePhone'].hash#" value="#patientInfo.patient.homePhone#">
					<label>Cell Phone</label><input type="text" name="#application.formMask['mobilePhone'].hash#" value="#patientInfo.patient.mobilePhone#">
					</cfoutput>	
		</div>
	
		<div class="thirds">
			<h4>Allergies:</h4>
			<cfoutput>
			<textarea name="#application.formMask['allergies'].hash#">#patientINfo.patient.allergies#</textarea>
			</cfoutput>
		</div>
	
	<div style="clear:both;"></div>

		

		<div class="thirds">
			<h4>Insurance Info</h4>

				<cfif structCount(patientInfo.patient.insurance)>
					
						<cfloop collection="#patientINfo.patient.insurance#" item="i">
							<cfoutput>
							<label>Carrier Name:</label><input type="text" name="#application.formMask['insCarrierName'].hash#" value="#application.insuranceCarriers[patientINfo.patient.insurance[i].carrierID].name#">
							<label>Carrier Phone:</label><input type="text" name="#application.formMask['insCarrierPhone'].hash#" value="#patientINfo.patient.insurance[i].carrierPhone#">
							<label>Insurance Name:</label><input type="text" name="#application.formMask['insInsuranceName'].hash#" value="#patientINfo.patient.insurance[i].name#">
							<label>Group Number:</label><input type="text" name="#application.formMask['insGroupNumber'].hash#" value="#patientInfo.patient.insurance[i].groupNumber#">
							<label>PCN Number:</label><input type="text" name="#application.formMask['insPCNNumber'].hash#" value="#patientInfo.patient.insurance[i].pcnNumber#">
							<label>Plan Number:</label><input type="text" name="#application.formMask['insPlanNumber'].hash#" value="#patientInfo.patient.insurance[i].planNumber#">
							<label>Bin Number:</label><input type="text" name="#application.formMask['insBinNumber'].hash#" value="#patientInfo.patient.insurance[i].binNumber#">
							</cfoutput>
							<cfbreak>
						</cfloop>
					
				<cfelse>
					
						<cfoutput>
						<label>Carrier Name:</label><input type="text" name="#application.formMask['insCarrierName'].hash#" value="">
						<label>Carrier Phone:</label><input type="text" name="#application.formMask['insCarrierPhone'].hash#" value="">
						<label>Insurance Name:</label><input type="text" name="#application.formMask['insInsuranceName'].hash#" value="">
						<label>Group Number:</label><input type="text" name="#application.formMask['insGroupNumber'].hash#" value="">
						<label>PCN Number:</label><input type="text" name="#application.formMask['insPCNNumber'].hash#" value="">
						<label>Plan Number:</label><input type="text" name="#application.formMask['insPlanNumber'].hash#" value="">
						<label>Bin Number:</label><input type="text" name="#application.formMask['insBinNumber'].hash#" value="">
						</cfoutput>
					
				</cfif>
			
			<cfoutput>
				<input type="hidden" name="#application.formMask['patientID'].hash#" value="#params.patient#">
			</cfoutput>
			
		</div>
		<div id="patInfoPopImage">
				<img src="/images/noPhoto.jpg" id="patInfoPopInsImage">
				<a href="javascript:togglePatientCardUpload();"><span class="contBtnDiv blueCont contBtnArrow"> Upload</span></a>
			</div>
	</form>
	
	</div>
	
	
	<!--- Order History Container --->
	<div id="patInfoPopOrderHistory" style="display:none;">
		<h4>Perscription History</h4>
		<table class="table">
			<thead>
				<tr>
					<th>Prescription Number</th>
					<th>Order Date</th>
					<th>View Order</th>
					<th>View Authorization</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td>No Previous Prescriptions for this Patient were found</td>
					<td></td>
					<td></td>
					<td></td>
				</tr>
			</tbody>
		</table>
	</div>

	<!--- Order Notes Container --->
	<div id="patInfoPopNotesContainer" style="display:none;">
		<h4>Patient Notes</h4>
		
	</div>
	
<!--- End of PatInfo Full Container --->
</div>
	
	<div  class="btnRow" style="clear:both;">
		<ul>
			<a href="javascript:closeDialog();"><li class="contBtnDiv redCont contBtnX">Close</li></a>
			<a href="javascript:savePatientProfileInfo();"><li class="contBtnDiv blueCont contBtnArrow">Save</li></a>
		</ul>
	</div>
	


</div>

</cfif>