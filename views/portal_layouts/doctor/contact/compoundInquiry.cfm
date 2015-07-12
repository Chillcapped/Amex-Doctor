<div id="btmContactContainer" class="clear">
	<h2 class="createRxSectionTitle">Custom Compound Inquiry</h4>
	<div class="yellowGrad alertBox"><i class="fa fa-exclamation-circle" style="margin: 0 10px 0 0;"></i> Please call our pharmacy technicians for immediate assistance</div>

	<div id="customCompInquiryTop">	
		<div id="customCompInquiryLabels">
			<ul>
				<li>Compound Name</li>
				<li>Intended Use</li>
			</ul>
		</div>
		<div id="customCompInquiryInputs">
			<input type="text" name="compoundName">
			<textarea name="intendedUse"></textarea>
		</div>
	</div>
	
	<div id="customCompInquiryTable">
		<table class="table">
			<thead>
				<tr>
					<th style="width:270px;">Name</th>
					<th style="width:100px;">Total Amount</th>
					<th style="width:100px;">Dosage</th>
					<th style="width:100px;">Interval</th>
					<th>Refills</th>
				</tr>
			</thead>
			<tbody>
					<tr>
						<td id="compInquiryNameTD">Compound Name</td>
						<td><input type="text" name="ammount" value="" placeholder="Enter Ammount" style="width: 112px;"></td>
						<td><input type="text" name="dosage" value="" placeholder="Dosage" style="width: 112px;"></td>
						<td><input type="text" name="interval" value="" placeholder="Interval" style="width:187px;"></td>
						<td><input type="text" name="refills" value="" placeholder="Refills"  style="width:80px;"></td>
					</tr>
					<tr>
						<td><a href="javascript:addIngredientToCustomInquiry();" id="addCustomInquiryIngBtn"><div class="contBtnDiv blueCont contBtnAdd" style="margin: 10px 5px 1px 5px !important;">Ingredient</div></a></td>
						<td colspan="3"><input type="text" name="compIngredient1" placeholder="Ingredient Name"></td>
						<td class="customInquiryIngredientPercentTD"><input type="text" name="compIngredientPercent1" placeholder="Ingredient %"></td>
					<!-- 	<td class="hiddenItem">-</td>
						<td class="hiddenItem">-</td> -->
					</tr>
			</tbody>
		</table>
	</div>
	
	<div class="btnRow">
		
			<a href="javascript:closeDialog();"><div class="contBtnDiv redCont contBtnX">Cancel</div></a>
			<a href="javascript:submitCustomInquiry();"><div class="contBtnDiv blueCont contBtnArrow">Submit Inquiry</div></a>
		
	</div>
	
	<div style="clear:both; margin:10px 0; overflow:auto;"></div>
		<div class="yellowGrad alertBox"><i class="fa fa-exclamation-circle" style="margin: 0 10px 0 0;"></i> Submitting or cancelling a custom compound inquiry does not affect the current prescription.</div>
	
	
	
</div>