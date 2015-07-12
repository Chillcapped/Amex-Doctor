

<h2>Create Prescription</h2>
	<form action="/doctor/createRx" method="post">
		<!--- Patient Info --->
		<div id="createRxTop" class="clear createRxContentItem">
			<h4>Patient Info</h4>
			<div class="createRxPtInfo">
				<div class="createRxLabelList">
					<ul>
						<li><label>Name</label></li>
						<li><label>Phone</label></li>
						<li><label>Emai</label></li>
						<li><label>DOB</label></li>
						<li><label>SSN</label></li>
					</ul>
				</div>
				<div class="createRxPtInputs">
					<ul>
						<cfoutput>
						<input type="text" name="name" value="#params.patient.firstName# #params.patient.lastName#" placeholder="Name">
						<input type="text" name="phone" value="#params.patient.homePhone#" placeholder="Phone">
						<input type="text" name="email" value="#params.patient.email#" placeholder="Email">
						<input type="text" name="dob" value="#params.patient.dob_Full#" placeholder="DOB">
						<input type="text" name="ssn" value="#params.patient.SSN#" placeholder="SSN">
						</cfoutput>
					</ul>
				</div>
			</div>
			
			<div class="createRxPtInfo">
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
					
					<!--- Drop Down select of patients address --->
					<cfif structCount(params.patient.addresses)>
						<select name="addressID">
							<cfoutput>
							<option value="#params.patient.addresses.addressID#">#params.patient.addresses.address1#</option>
							</cfoutput>
						</select>
					</cfif>
					
					<ul>
						<input type="text" name="address1" value="" placeholder="Address1">
						<input type="text" name="address2" value="" placeholder="Address2">
						<input type="text" name="city" value="" placeholder="City">
						<input type="text" name="state" value="" placeholder="State">
						<input type="text" name="zip" value="" placeholder="Zip">
					</ul>
				</div>	
			</div>
			
			<div id="createRxBtnPtMenu">
				<ul class="clear">
					<li><a href="/patient/#params.patientID#">View All Patient Info</a></li>
					<li><a href="/createRx">Select Different Patient</a></li>
				</ul>
			</div>
			
		</div>
		<!--- End Patient Info --->
		
		
		
		
		<!--- Order Info --->
		<div id="createRxMiddle" class="clear createRxContentItem">
			<h4>Order Info</h4>
			<label>Prescription #:</label>
			<input type="text" name="rxNumber" value="" placeholder="">
			<label>Written Date:</label>
			<input type="text" name="rxDate" value="" placeholder="">
			
		</div>
		
		
		<!--- Prescription Info --->
		<div id="createRxBtm" class="clear createRxContentItem">
			<h4>Prescription</h4>
			<div id="rxInfoContainer">
				<div id="createRxBtnTopContainer">
					<ul class="clear">
						<a href="javascript:showContent('preferred');"><li>Preferred Compound</li></a>
						<a href="javascript:showContent('custom');"><li>Custom Compound</li></a>
						<a href="javascript:showContent('manufactured')"><li>Manufacturer Drug</li></a>
					</ul>
				</div>
				<!--- Contents are blank by default --->
				
				<!--- Test Table --->
				<table cellspacing="0" cellpadding="0">
					<thead>
						<tr>
							<th>ID</th>
							<th id="createRxNameTH">Name</th>
							<th id="createRxTotalTH">Total Ammount</th>
							<th id="createRxDosageTH">Dosage</th>
							<th id="createRxIntervalTH">Interval</th>
							<th id="createRxRefillTH">Refills</th>
						</tr>
					</thead>
					<tbody>
						
						<!--- Added Per Item --->

						<!--- Ingredient --->
						<tr>
							<td>1</td>
							<td><input type="text" name="itemName1" value="Amocicillin"></td>
							<td><input type="text" name="itemAmmount1" value="30 Pills"></td>
							<td><input type="text" name="itemDosage1" value="10g Pills"></td>
							<td><input type="text" name="itemInterval1" value="Every 4 Hours"></td>
							<td><input type="text" name="itemRefills1" value="1"></td>
							<input type="hidden" name="itemType1" value="ingredient">
						</tr>
						
						
						<!--- Compound --->
						<tr>
							<td>2</td>
							<td><input type="text" name="itemName2" value="Amocicillin"></td>
							<td><input type="text" name="itemAmmount2" value="30 Pills"></td>
							<td><input type="text" name="itemDosage2" value="10g Pills"></td>
							<td><input type="text" name="itemInterval2" value="Every 4 Hours"></td>
							<td><input type="text" name="itemRefills2" value="1"></td>
							
							<!--- Hidden INputs--->
							<input type="hidden" name="itemType2" value="compound">
							<input type="hidden" name="itemIngredientCount2" value="3">
						</tr>
						<!---  Add Bottom Rows  --->
						<tr>
							<td>-</td>
							<td><a href="">Ingredient +</a></td>
							<td class="ingredientTD">Ingredient 1</td>
							<td class="ingredientTD ingredientPercTD"><input class="ingredientInput" type="text" name="itemIngredientPerc1" value="20%"></td>
						</tr>
						<tr>
							<td>-</td>
							<td>-</td>
							<td class="ingredientTD">Ingredient 2</td>
							<td class="ingredientTD ingredientPercTD"><input class="ingredientInput" type="text" name="itemIngredientPerc2" value="30%"></td>
						</tr>
						<tr>
							<td>-</td>
							<td>-</td>
							<td class="ingredientTD">Ingredient 3</td>
							<td class="ingredientTD ingredientPercTD"><input class="ingredientInput" type="text" name="itemIngredientPerc3" value="40%"></td>
						</tr>
						
						<!--- Manufactured Drug --->
						<tr>
							<td>3</td>
							<td><input type="text" name="itemName3" value="Amocicillin"></td>
							<td><input type="text" name="itemAmmount3" value="30 Pills"></td>
							<td><input type="text" name="itemDosage3" value="10g Pills"></td>
							<td><input type="text" name="itemInterval3" value="Every 4 Hours"></td>
							<td><input type="text" name="itemRefills3" value="1"></td>
							
							<input type="hidden" name="itemType3" value="manfactured">
							<input type="hidden" name="itemID" value="{manfacturedItemID}">
						</tr>

					</tbody>
				</table>
			</div>
			
			
			<div id="createRxBtnBtmContainer">
				<ul>
					<a href="javascript:submitRx();"><li><input type="submit" value="Submit Prescription" style="float: right;"></li></a>
					<a href="javascript:closeRxPopup();"><li>Cancel</li></a>
				</ul>
			</div>
			
			
			
		</div>
	
		
	</form>