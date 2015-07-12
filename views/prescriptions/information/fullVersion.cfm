<div id="prescriptionFullContainer">
	<div id="prescriptionFullTopNav">
		<ul class="tabs">
			<a href="javascript:changeRxInfoContent('details');"><li>Details</li></a>
			<a href="javascript:changeRxInfoContent('messages');"><li>Message</li></a>
			<a href="javascript:changeRxInfoContent('notes');"><li>Notes</li></a>
			<a href="javascript:changeRxInfoContent('timeline');"><li>Timeline</li></a>
		</ul>
	</div>
	<div style="clear:both;"></div>
	<div class="thirds">
		<h4>Patient Details</h4>
		<ul>
			<cfoutput>
				<li><label>Name</label> <input type="text" name="#hash('name')#" value="#rx.prescription.firstName# #rx.prescription.middleName# #rx.prescription.lastName#"></li>
				<li><label>DOB</label> <input type="text" name="#hash('dob_full')#" value="#rx.prescription.dob_full#"></li>
				<li><label>Phone</label> <input type="text" name="#hash('homePhone')#" value="#rx.prescription.homePhone#"></li>
				<li><label>SSN</label> <input type="text" name="#hash('ssn')#" value="#rx.prescription.ssn#"></li>
			</cfoutput>
		</ul>
	</div>
	<div class="thirds">
		<h4>Billing Address</h4>
		<ul>
			<cfoutput>
				<li><label>Address1</label> <input type="text" name="#hash('billAddress1')#" value="#rx.prescription.billAddress1#"></li>
				<li><label>Address2</label> <input type="text" name="#hash('billAddress2')#" value="#rx.prescription.billAddress2#"></li>
				<li><label>City</label> <input type="text" name="#hash('billCity')#" value="#rx.prescription.billCity#"></li>
				<li><label>State</label>  <input type="text" name="#hash('billState')#" value="#rx.prescription.billState#"></li>
				<li><label>Zip</label> <input type="text" name="#hash('billZip')#" value="#rx.prescription.billZip#"></li>
			</cfoutput>
		</ul>
	</div>
	<div class="thirds">
		<h4>Shipping Address</h4>
		<ul>
			<cfoutput>
				<li><label>Address1</label> <input type="text" name="#hash('shipAddress1')#" value="#rx.prescription.shipAddress1#"></li>
				<li><label>Address2</label> <input type="text" name="#hash('shipAddress2')#" value="#rx.prescription.shipAddress2#"></li>
				<li><label>City</label> <input type="text" name="#hash('shipCity')#" value="#rx.prescription.shipCity#"></li>
				<li><label>State</label>  <input type="text" name="#hash('shipState')#" value="#rx.prescription.shipState#"></li>
				<li><label>Zip</label> <input type="text" name="#hash('shipZip')#" value="#rx.prescription.shipZip#"></li>
			</cfoutput>
		</ul>
	</div>
	<div style="clear:both;"></div>
	<div class="thirds">
		<h4>Insurance</h4>
		
			<cfoutput>
				<label>Carrier Name</label> <input type="text" name="#hash('insCarrierName')#" value="#rx.prescription.insCarrierName#">
				<label>Insurance Name</label> <input type="text" name="#hash('insPlanName')#" value="#rx.prescription.insPlanName#">
				<label>Group Number</label> <input type="text" name="#hash('insGroupNumber')#" value="#rx.prescription.insGroupNumber#">
				<label>PCN Number</label> <input type="text" name="#hash('insPCNNumber')#" value="#rx.prescription.insPCNNumber#">
				<label>Carrier Phone</label> <input type="text" name="#hash('insCarrierPhone')#" value="#rx.prescription.insCarrierPhone#">
				<label>Plan Number</label> <input type="text" name="#hash('insPlanNumber')#" value="#rx.prescription.insPlanNumber#">
				<label>Bin Number</label> <input type="text" name="#hash('insBinNumber')#" value="#rx.prescription.insBinNumber#">

	<div style="clear:both;"></div>
<div class="btnRow">
					<a href="javascript:viewRxInsuranceCard('#rx.prescription.rxID#');"><div class="contBtnDiv blueCont contBtnArrow">View Insurance Card</div></a>
					<a href="javascript:updateRxInsuranceInfo('#rx.prescription.rxID#');"><div class="contBtnDiv blueCont contBtnArrow">Update Insurance Info</div></a>
				</div>
			</cfoutput>
		
	</div>
	<div class="thirds">
		<h4>Order Information</h4>
		
			<cfoutput>
				<label>Written Date</label> <input type="text" name="#hash('createDate')#" value="#rx.prescription.createDate#">
				<label>Prescription ##</label> <input type="text" name="#hash('prescriptionID')#" value="#rx.prescription.rxID#">
				<label>Status</label> 
					<select name="status">
						<cfloop collection="#application.rxStatus#" item="i">
							<cfoutput>
								<cfif rx.prescription.status eQ i>
									<option value="#i#" selected>#application.rxStatus[i].name#</option>
									<cfelse>
										<option value="#i#">#application.rxStatus[i].name#</option>
									</cfif>
								</cfoutput>
							</cfloop>
						</select>
					
					<label>Notes</label> <textarea name=""></textarea>
						<div style="clear:both;"></div>
<div class="btnRow">
<a href="javascript:updateSmallRxInfo();"><li class="contBtnDiv blueCont contBtnArrow">Update Order Info</li></a>
</div>
				</cfoutput>
		</div>
	
	<div style="clear:both;"></div>
	<div id="prescriptionPopContents">
		<h4>Prescription</h3>
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
					<cfloop collection="#rx.prescription.contents#" item="i">
						<cfoutput>
							<tr>
								<td>1</td>
								<td>#rx.prescription.contents[i].name#</td>
								<td>#rx.prescription.contents[i].totalAmmount#</td>
								<td>#rx.prescription.contents[i].dosage#</td>
								<td>#rx.prescription.contents[i].interval#</td>
								<td>#rx.prescription.contents[i].roa#</td>
								<td>#rx.prescription.contents[i].refills#</td>
							</tr>
							<cfif rx.prescription.contents[i].type EQ "compound">
								<cfloop collection="#rx.prescription.contents[i].ingredients#" item="x">
									<tr>
										<td></td>
										<td></td>
										<td></td>
										<td></td>
										<td>#rx.prescription.contents[i].ingredients[x]['name']#</td>
										<td>#rx.prescription.contents[i].ingredients[x]['dosage']#</td>
										<td>#rx.prescription.contents[i].ingredients[x]['percentage']#</td>
									</tr>	
								</cfloop>
							</cfif>
						</cfoutput>
					</cfloop>
				</tbody>
			</table>

		<div style="clear:both;"></div>
			<div class="thirds">
				<label>Allergies</label>
				<textarea></textarea>
			</div>
		</div>
		<div style="clear:both;"></div>
		<div class="btnRow">
			<ul>
				<a href="javascript:closeDialog();"><li class="contBtnDiv redCont contBtnX">Close</li></a>
				<a href="javascript:goToPrintLayout('')"><li class="contBtnDiv blueCont contBtnArrow">Print Rx Script</li></a>
				<a href="javascript:saveRxInfo();"><li class="contBtnDiv blueCont contBtnArrow">Save Changes</li></a>
			</ul>
		</div>	
		
	</div>