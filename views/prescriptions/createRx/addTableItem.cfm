<cfparam name="params.item" default="1">


<cfif params.type EQ "compound">
	<tr>
		<cfoutput>
		<td>#params.item#</td>
		<td><input type="text"  class="rxItemName" name="itemName#params.item#" value="#application.drugs['compounds'][params.id].name#"></td>
		<td><input type="text" name="itemAmmount#params.item#" class="ammountRxInput" value="30 Pills"></td>
		<td><input type="text" name="itemDosage#params.item#" value="10g Pills"></td>
		<td><input type="text" name="itemInterval#params.item#" value="Every 4 Hours"></td>
		<td><input type="text" name="itemROA#params.item#" value="Oral"></td>
		<td><input type="text" name="itemRefills#params.item#" class="refillRxInput" value="1"></td>
		
		<!--- Hidden INputs --->
		<input type="hidden" name="itemType#params.item#" value="compound">
		<input type="hidden" name="itemID#params.item#" value="#params.id#">
	</tr>
	<!---  Add Bottom Rows  --->
	<cfset rowCount = 0>
	<cfloop collection="#application.drugs['compounds'][params.id].ingredients#" item="i">
		<cfset rowCount++>
		<tr>
			<td colspan="3"></td>
			<td colspan="2" class="ingredientTD">#i#</td>
			<td colspan="2" class="ingredientTD ingredientPercTD"> #application.drugs['compounds'][params.id].ingredients[i].percentage# %</td>
		
		</tr>
	</cfloop>
	</cfoutput>
	
<cfelseif params.type EQ "manufactured">
	<cfoutput>
		<tr>
			<td>#params.item#</td>
			<td><input type="text" class="rxItemName" name="itemName#params.item#" value="#application.drugs['manufactured'][params.id].name#"></td>
			<td><input type="text" name="itemAmmount#params.item#" value="30 Pills"></td>
			<td><input type="text" name="itemDosage#params.item#" value="10g Pills"></td>
			<td><input type="text" name="itemInterval#params.item#" value="Every 4 Hours"></td>
			<td><input type="text" name="itemROA#params.item#" value="Oral"></td>
			<td><input type="text" name="itemRefills#params.item#" value="1"></td>
			<input type="hidden" name="itemType#params.item#" value="manufactured">
			<input type="hidden" name="itemID#params.item#" value="#params.id#">
		</tr>
	</cfoutput>
</cfif>