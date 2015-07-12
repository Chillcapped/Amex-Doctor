<h4>Create Compound</h4>

<form action="/pharmacist/createCompound" method="post">
	<label>Name</label>
	<input type="text" name="name" value="" placeholder="Compound Name" />
	
	<br /><br />
	
	<label>Category:</label>
	<select name="category">
		<cfset catTypeID = application.categoryTypeLookup['compounds'].id>
		<cfloop collection="#application.categories[catTypeID].categories#" item="i">
			<cfoutput>
				<option value="#application.categories[catTypeID].categories[i].categoryID#">#application.categories[catTypeID].categories[i].name#</option>
			</cfoutput>
		</cfloop>
	</select>
	
	
	<!---
		For now list ingredients but we should have an add button w/ ajax 
	--->

	<h4>Ingredients</h4>
		<ul>
		<cfloop collection="#application.ingredients#" item="i">
			<cfoutput>
			<li><input type="checkbox" name="#application.ingredients[i].ingredientId#" value="true">#application.ingredients[i].name#</li>
			</cfoutput>
		</cfloop>
		</ul>
	<input type="submit" value="Create" />
</form>
	
