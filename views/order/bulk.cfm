
<!--- Get patients --->
<cfinvoke component="api.doctor" method="getPatients" returnVariable="patientLookup">
	<cfinvokeargument name="doctorID" value="#session.user.userID#">
	<cfinvokeargument name="authToken" value="#session.user.authToken#">
	<cfinvokeargument name="returnType" value="struct">
	<cfinvokeargument name="enc" value="false">
</cfinvoke>

<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/pageHeader")#</cfoutput>
<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/sideMenu")#</cfoutput>


<div id="contentContainer">
	<h4>Bulk Order - Select Patients</h4>
	<div class="bulkOrderSteps" id="createRxCurrentStepContainer">
		<ul>
			<li id="selectPatientStep" class="activeRxStep">
				<span class="stepNumber activeStep">1</span>
				<span class="stepText activeStepText">Select Patients </span>
			</li>
			<li id="selectMedicationStep">
				<span class="stepNumber">2</span>
				<span class="stepText">Select Medications</span>
			</li>
			<li id="authorizedStep">
				<span class="stepNumber">3</span>
				<span class="stepText">Delivery Options</span>
			</li>
			<li id="authorizedStep">
				<span class="stepNumber">4</span>
				<span class="stepText">Finalize Order</span>
			</li>
		</ul>
	</div>
      <div id="content" class="selectTypeContainer bulkOrderContent">
          <p>Patients with active prescriptions:</p>

					<div id="boContainer">

						<form action="/order/bulkpreview" method="post" id="bulkOrderForm">
							<div id="boPatients">
								<div id="boAmexPatients">
										<ul>
											<cfloop from="1" to="#arrayLen(patientLookup.patients)#" index="i">
													<cfoutput>
												<li><input type="checkbox" id="#patientLookup.patients[i]['_source'].patientID#" name="pt:#patientLookup.patients[i]['_source'].patientID#">
													<a href="" class="black">#patientLookup.patients[i]['_source'].firstName# #patientLookup.patients[i]['_source'].lastName#</a></li>
												</cfoutput>
											</cfloop>
										</li>
								</div>
							</div>
							<div id="boFormControls">
								<ul>
									<li class="fullBtn">Back</li>
									<a href="javascript:submitBulkPatientForm();"><li class="right fullBtn">Next</li><a/>
								</ul>
							</div>
						</form>

					</div>

      </div>
</div>
