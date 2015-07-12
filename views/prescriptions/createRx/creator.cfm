<cfset requiredFormData = "shippingSelect,billingSelect,patientID">
<cfset formData = structNew()>

<!-- Parse the Form Dataz -->
<cfloop list="#structKeyList(params)#" index="i">
	<cfif structKeyExists(application.formMaskLookUp, i) and listFind(requiredFormData, application.formMaskLookUp[i].name)>
		<cfset formData[application.formMaskLookUp[i].name] = structNew()>
		<cfset formData[application.formMaskLookUp[i].name].hash = i>
		<cfset formData[application.formMaskLookUp[i].name].name = application.formMaskLookUp[i].name>
		<cfset formData[application.formMaskLookUp[i].name].value = params[i]>
	</cfif>
</cfloop>


<!-- View Template for Creating an Rx -->

<div id="rxCreatorContainer">
		<!-- Prescription Info -->
		<div id="createRxBtm" class="clear createRxContentItem">
			<h2 class="createRxSectionTitle">Prescription</h2>
			<div id="rxInfoContainer">

				<div id="createRxBtnTopContainer">
					<ul class="clear">
						<a href="javascript:showRxMedContent('compound');"><li class="contBtnDiv blueCont contBtnAdd">Preferred Compound</li></a>
						<a href="javascript:showRxCustomContact();"><li class="contBtnDiv blueCont contBtnAdd">Custom Compound</li></a>
						<a href="javascript:showRxMedContent('manufactured')"><li class="contBtnDiv blueCont contBtnAdd">Manufacturer Drug</li></a>

					</ul>
				</div>
				<img src="/images/avastin_640.jpg" id="avastinTemp" />
				<!-- Container for Ajax contents of Medications when adding -->
				<div id="medBrowseContainer" style="display:none;"></div>

				<!-- Contents are blank by default -->
				<div id="createRxTableContainer">
					<form action="" method="post" id="createMedForm">
					<input type="hidden" name="numItems" id="createRxNumItems" value="0">

					<cfloop collection="#formData#" item="i">
						<cfoutput>
						<input type="hidden" name="#formData[i].hash#" value="#formData[i].value#" />
						</cfoutput>
					</cfloop>
						<!-- Test Table -->
						<table class="table">
							<thead>
								<tr>
									<th>ID</th>
									<th id="createRxNameTH">Name</th>
									<th id="createRxTotalTH">Total Ammount</th>
									<th id="createRxDosageTH">Dosage</th>
									<th id="createRxIntervalTH">Interval</th>
									<th id="createRxROATH">ROA</th>
									<th id="createRxRefillTH">Refills</th>
								</tr>
							</thead>
							<tbody>
							<tr id="emptyRxRow">
								<td id="noItemsAddedTD">No Items are currently added to this prescription</td>

							</tr>
							</tbody>
						</table>
					</form>
				</div>

				<div class="clear"></div>
			</div>


			<div id="createRxBtnBtmContainer">
				<ul class="clear">
					<a href="javascript:closeDialog();"><li class="contBtnDiv redCont contBtnX">Cancel</li></a>
					<a href="javascript:createNewRx();"><li id="submitRxBtn" class="contBtnDiv blueCont contBtnArrow ">Back to Patient</li></a>
					<a href="javascript:createNewRx();"><li id="submitRxBtn" class="contBtnDiv blueCont contBtnArrow ">Submit Prescription</li></a>
					</ul>
			</div>
		</div>

</div>
