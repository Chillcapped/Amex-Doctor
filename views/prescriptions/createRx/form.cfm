<cfinvoke component="api.Encryption" method="encryptFormID" returnvariable="ePatientID"> 
	<cfinvokeargument name="id" value="#patientInfo.patient.patientID#">
</cfinvoke>

<div id="createRxSelectedPatientCnt">
	<div id="createRxCurrentStepContainer">
		<ul>
			<li id="selectPatientStep" class="activeRxStep">
				<span class="stepNumber activeStep" >1</span>
				<span class="stepText activeStepText">Select Patient </span>
			</li>
			<li id="selectMedicationStep">
				<span class="stepNumber">2</span>
				<span class="stepText">Select Medications</span>
			</li>
			<li id="authorizedStep">
				<span class="stepNumber">3</span>
				<span class="stepText">Authorize</span>
			</li>
		</ul>
	</div>
	<div id="createRxStepContentContainer" >
		<form action="/createRx" method="post" id="createNewRxForm">
			<!-- Pass Encrypted Patient ID -->
			<cfoutput><input type="hidden" name="#application.formMask['patientID'].hash#" id="createRxInput1" value="#ePatientID#"></cfoutput>
			<!-- Patient Info -->
			<div id="createRxTop" class="clear createRxContentItem">
				<h2 class="createRxSectionTitle">Create Prescription</h2>
	
				<div class="createRxPtInfo">
					<h4>Patient Info</h4>
					<div class="createRxLabelList">
						<ul>
							<li><label>Name</label></li>
							<li><label>DOB</label></li>
							<li><label>SSN</label></li>
							<li><label>Email</label></li>
							<li><label>Home Phone</label></li>
							<li><label>Mobile Phone</label></li>
						</ul>
					</div>
					<div class="createRxPtInputs">
						<ul>
							<cfoutput>
							<li><input type="text" name="#application.formMask['FirstName'].hash#"" value="#patientInfo.patient.firstName# #patientInfo.patient.lastName#" placeholder="Name"></li>
							<li><input type="text" name="#application.formMask['dob'].hash#"" value="#patientInfo.patient.dob_Full#" placeholder="DOB"></li>
							<li><input type="text" name="#application.formMask['ssn'].hash#"" value="#patientInfo.patient.SSN#" placeholder="SSN"></li>
							<li><input type="text" name="#application.formMask['email'].hash#"" value="#patientInfo.patient.email#" placeholder="Email"></li>
							<li><input type="text" name="#application.formMask['homePhone'].hash#"" value="#patientInfo.patient.homePhone#" placeholder="Phone"></li>
							<li><input type="text" name="#application.formMask['mobilePhone'].hash#"" value="#patientInfo.patient.homePhone#" placeholder="Phone"></li>
							</cfoutput>
						</ul>
					</div>
				</div>
				<div class="createRxPtInfo">
					<h4>Insurance</h4>
					<cfoutput>
					<div style="clear:both;"></div>
					<select id="createRxInsuranceSelect" class="patientInfoSelect"  name="#application.formMask['insuranceSelect'].hash#">
						<cfloop collection="#patientINfo.patient.insurance#" item="i">
							<option value="#i#">#patientInfo.patient.insurance[i].carrierID# #patientInfo.patient.insurance[i].name#</option>
						</cfloop>
					</select>
					</cfoutput>
					<div class="insuranceInfoListItems">
						<ul>
							<li><label>Carrier Name:</label></li>
							<li><label>Insurance Name:</label></li>
							<li><label>Group Number:</label></li>
							<li><label>PCN Number:</label></li>
							<li><label>Carrier Phone:</label></li>
							<li><label>Plan Number:</label></li>
							<li><label>Bin Number:</label></li>
						</ul>
					</div>
					<div class="createRxPtInputs">
						<cfif structCount(patientInfo.patient.insurance)>
						<ul>
							<cfloop collection="#patientINfo.patient.insurance#" item="i">
								<cfoutput>
								<li><input type="text" name="#application.formMask['insCarrierName'].hash#" value="#application.insuranceCarriers[patientINfo.patient.insurance[i].carrierID].name#"></li>
								<li><input type="text" name="#application.formMask['insCarrierPhone'].hash#" value="#patientINfo.patient.insurance[i].carrierPhone#"></li>
								<li><input type="text" name="#application.formMask['insInsuranceName'].hash#" value="#patientINfo.patient.insurance[i].name#"></li>
								<li><input type="text" name="#application.formMask['insGroupNumber'].hash#" value="#patientInfo.patient.insurance[i].groupNumber#"></li>
								<li><input type="text" name="#application.formMask['insPCNNumber'].hash#" value="#patientInfo.patient.insurance[i].pcnNumber#"></li>
								<li><input type="text" name="#application.formMask['insPlanNumber'].hash#" value="#patientInfo.patient.insurance[i].planNumber#"></li>
								<li><input type="text" name="#application.formMask['insBinNUmber'].hash#" value="#patientInfo.patient.insurance[i].binNumber#"></li>
								</cfoutput>
								<cfbreak>
							</cfloop>
						</ul>
					<cfelse>
						<ul>
							<cfoutput>
							<li><input type="text" name="#application.formMask['insCarrierName'].hash#" value=""></li>
							<li><input type="text" name="#application.formMask['insCarrierPhone'].hash#" value=""></li>
							<li><input type="text" name="#application.formMask['insInsuranceName'].hash#" value=""></li>
							<li><input type="text" name="#application.formMask['insGroupNumber'].hash#" value=""></li>
							<li><input type="text" name="#application.formMask['insPCNNumber'].hash#" value=""></li>
							<li><input type="text" name="#application.formMask['insPlanNumber'].hash#" value=""></li>
							<li><input type="text" name="#application.formMask['insBinNUmber'].hash#" value=""></li>
							</cfoutput>
						</ul>
					</cfif>
					</div>	
				</div>
				<div class="createRxPtInfo">
					<h4>Shipping</h4>
					<cfoutput>
					<select id="createRxShippingSelect" class="patientInfoSelect" name="#application.formMask['ShippingSelect'].hash#">
						<cfloop collection="#patientINfo.patient.address#" item="i">
							<cfif patientInfo.patient.address[i].addressType EQ "shipping">
								<option value="#i#">#patientInfo.patient.address[i].address1#</option>
							</cfif>
						</cfloop>
					</select>
					</cfoutput>
					<div class="createRxLabelList">
						<ul>
							<li><label>Address 1</label></li>
							<li><label>Address 2</label></li>
							<li><label>City</label></li>
							<li><label>State</label></li>
							<li><label>Zip</label></li>
						</ul>
					</div>
					<div class="createRxPtInputs">
						<cfif structKeyExists(patientInfo.patient, "primaryShipping")>
							<ul>
								<cfoutput>
								<li><input type="text" name="#application.formMask['shipAddress1'].hash#" placeholder="Address Line 1" value="#patientInfo.patient.address[patientInfo.patient.primaryShipping].address1#"></li>
								<li><input type="text" name="#application.formMask['shipAddress2'].hash#" placeholder="Address Line 2" value="#patientInfo.patient.address[patientInfo.patient.primaryShipping].address2#"></li>
								<li><input type="text" name="#application.formMask['shipCity'].hash#" placeholder="City" value="#patientInfo.patient.address[patientInfo.patient.primaryShipping].city#"></li>
								<li><input type="text" name="#application.formMask['shipState'].hash#"  placeholder="State" value="#patientInfo.patient.address[patientInfo.patient.primaryShipping].state#"></li>
								<li><input type="text" name="#application.formMask['shipZip'].hash#"  placeholder="Zip" value="#patientInfo.patient.address[patientInfo.patient.primaryShipping].zip#"></li>
								</cfoutput>
							</ul>
						<cfelse>
							<ul>	
								<cfoutput>
								<li><input type="text" name="#application.formMask['shipAddress1'].hash#" placeholder="Address Line 1" value=""></li>
								<li><input type="text" name="#application.formMask['shipAddress2'].hash#" placeholder="Address Line 2" value=""></li>
								<li><input type="text" name="#application.formMask['shipCity'].hash#" placeholder="City" value=""></li>
								<li><input type="text" name="#application.formMask['shipState'].hash#"  placeholder="State" value=""></li>
								<li><input type="text" name="#application.formMask['shipZip'].hash#"  placeholder="Zip" value=""></li>
								</cfoutput>
							</ul>	
						</cfif>
					</div>	
				</div>
				
				<div class="createRxPtInfo">
					<h4>Billing</h4>
					<cfoutput>
						<select id="createRxBillingSelect" class="patientInfoSelect clear" name="#application.formMask['billingSelect'].hash#">
							<cfloop collection="#patientINfo.patient.address#" item="i">
								<cfif patientInfo.patient.address[i].addressType EQ "billing">
									<option value="#i#">#patientInfo.patient.address[i].address1#</option>
								</cfif>
							</cfloop>
						</select>
					</cfoutput>
					<div class="createRxLabelList">
						<ul>
							<li><label>Address 1</label></li>
							<li><label>Address 2</label></li>
							<li><label>City</label></li>
							<li><label>State</label></li>
							<li><label>Zip</label></li>
						</ul>
					</div>
					<div class="createRxPtInputs">
						<!-- Drop Down select of patients address -->
	
						<cfif structKeyExists(patientInfo.patient, "primarybilling")>
							<cfoutput>
							<ul>
								<li><input type="text" name="#application.formMask['billAddress1'].hash#" placeholder="Address Line 1" value="#patientInfo.patient.address[patientInfo.patient.primaryBilling].address1#" /></li>
								<li><input type="text" name="#application.formMask['billAddress2'].hash#" placeholder="Address Line 2"  value="#patientInfo.patient.address[patientInfo.patient.primaryBilling].address2#" /></li>
								<li><input type="text" name="#application.formMask['billCity'].hash#" placeholder="City"  value="#patientInfo.patient.address[patientInfo.patient.primaryBilling].city#"/></li>
								<li><input type="text" name="#application.formMask['billState'].hash#"  placeholder="State" value="#patientInfo.patient.address[patientInfo.patient.primaryBilling].state#" /></li>
								<li><input type="text" name="#application.formMask['billZip'].hash#" placeholder="Zip"  value="#patientInfo.patient.address[patientInfo.patient.primaryBilling].zip#"/></li>
							</ul>	
							</cfoutput>
						<cfelse>
							<ul>
								<cfoutput>
								<li><input type="text" name="#application.formMask['billAddress1'].hash#" placeholder="Address Line 1" value="" /></li>
								<li><input type="text" name="#application.formMask['billAddress2'].hash#" placeholder="Address Line 2"  value="" /></li>
								<li><input type="text" name="#application.formMask['billCity'].hash#" placeholder="City"  value="" /></li>
								<li><input type="text" name="#application.formMask['billState'].hash#"  placeholder="State" value="" /></li>
								<li><input type="text" name="#application.formMask['billZip'].hash#" placeholder="Zip"  value="" /></li>
								</cfoutput>
							</ul>
						</cfif>
					</div>	
				</div>
				
				<div id="createRxBtnPtMenu">
					<ul class="clear">
						<cfoutput><a href="javascript:showPatientInfo('#epatientID#');"><li class="contBtnDiv blueCont contBtnArrow">View Patient Profile</li></a></cfoutput>
						<a href="javascript:showCreateRx();"><li class="contBtnDiv blueCont contBtnArrow">Select Different Patient</li></a>
						<cfoutput><a href="javascript:sendToCreator('#epatientID#');"><li class="contBtnDiv blueCont contBtnArrow">Proceed to RX</li></a></cfoutput>
					</ul>
				</div>
				
			</div>
			<!--- End Patient Info --->
			
		
		</form>
		
	</div>	

</div>