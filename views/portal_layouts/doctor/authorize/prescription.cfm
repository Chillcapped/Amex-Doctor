


	<div id="docAuthorizeRxContainer" class="fullBlock">
<!--- Doctor Authorize Template --->

		<div id="authorizeRxPreviewContainer">
		<h4>Authorize Prescription</h4>
			<div id="authRxPreviewGeneral">	
					<cfoutput>
					<label>Patient Name:</label><div class="infoLine">#prescriptionInfo.prescription.firstNAME# #prescriptionInfo.prescription.LASTNAME#</div>
					<label>DOB:</label><div class="infoLine">#prescriptionInfo.prescription.dob_full#</div></div>
					<label>SSN:</label><div class="infoLine">#prescriptionInfo.prescription.ssn#</div>
					<label>Prescription Date:</label><div class="infoLine">#dateFormat(prescriptionInfo.prescription.createDate, "mm/dd/yyyy")#</div>
					

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
	<div class="sigWrapper">
		<iframe class="clear" src="/prescriptions/sign/" height="250" width="750" id="signPadFrame" /> 
	</div>
	</div>
	

	<div id="rxSecurityCodeContainer" style="display:none;"></div>
	
	

