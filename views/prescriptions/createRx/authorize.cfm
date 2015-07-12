<cfparam name="params.view" default="basic">

<cfif params.view EQ "full">
	<div id="createRxSelectedPatientCnt">
	<div id="createRxCurrentStepContainer">
		<ul>
			<li id="selectPatientStep">
				<span class="stepNumber" >1</span>
				<span class="stepText">Select Patient </span>
			</li>
			<li id="selectMedicationStep">
				<span class="stepNumber">2</span>
				<span class="stepText">Select Medications</span>
			</li>
			<li id="authorizedStep"  class="activeRxStep">
				<span class="stepNumber activeStep">3</span>
				<span class="stepText activeStepText">Authorize</span>
			</li>
		</ul>
	</div>
	<div id="createRxStepContentContainer" >
</cfif>
<!--- Doctor Authorize Template --->
	<div id="createRxAuthorizeRxContainer" class="">
		<div id="authorizeRxPreviewContainer">
		<h4>Authorize Prescription</h4>
			<div id="authRxPreviewGeneral">	
					<cfoutput>
					<div><label>Patient Name:</label><span>#prescriptionInfo.prescription.firstNAME# #prescriptionInfo.prescription.LASTNAME#</span></div>
					<div><label>DOB:</label><span>#prescriptionInfo.prescription.dob_full#</span></div>
					<div><label>SSN:</label><span>#prescriptionInfo.prescription.ssn#</span></div>
					<div><label>Prescription Date:</label><span>#dateFormat(prescriptionInfo.prescription.createDate, "mm/dd/yyyy")#</span></div>
				</ul>
				<input type="hidden" id="prescription" value="#prescriptionInfo.prescription.eRxID#" />
			</cfoutput>
			</div>
			<div id="authorizeRxPreviewContents" class="clear">
				<h4>Contents:</h4>
					<table class="table">
						<thead>
							<tr>
								<th>ID</th>
								<th>Name</th>
								<th>Total Ammount</th>
								<th>Dosage</th>
								<th>Interval</th>
								<th>ROA</th>
								<th>Refills</th>
							</tr>
						</thead>
						<tbody>
							<cfloop collection="#prescriptionInfo.prescription.contents#" item="i">
								<cfoutput>
									<tr>
										<td>1</td>
										<td>#prescriptionInfo.prescription.contents[i].name#</td>
										<td>#prescriptionInfo.prescription.contents[i].totalAmmount#</td>
										<td>#prescriptionInfo.prescription.contents[i].dosage#</td>
										<td>#prescriptionInfo.prescription.contents[i].interval#</td>
										<td>#prescriptionInfo.prescription.contents[i].roa#</td>
										<td>#prescriptionInfo.prescription.contents[i].refills#</td>
									</tr>
									<cfif prescriptionInfo.prescription.contents[i].type EQ "compound">
										<cfloop collection="#prescriptionInfo.prescription.contents[i].ingredients#" item="x">
											<tr>
												<td></td>
												<td></td>
												<td></td>
												<td></td>
												<td>#prescriptionInfo.prescription.contents[i].ingredients[x]['name']#</td>
												<td>#prescriptionInfo.prescription.contents[i].ingredients[x]['dosage']#</td>
												<td>#prescriptionInfo.prescription.contents[i].ingredients[x]['percentage']#</td>
											</tr>	
										</cfloop>
									</cfif>
								</cfoutput>
							</cfloop>
						</tbody>
					</table>
				</div>
		</div>
		<!--- Include Iframe of Sign --->

		<div class="signWrapper"><iframe class="clear" src="/prescriptions/sign/" height="250" width="750" id="signPadFrame" /> </div>
	
	</div>
	

	<div id="rxSecurityCodeContainer" style="display:none;"></div>
	
	
<cfif params.view EQ "full">
	</div>
</cfif>
