
<h2>Create New Manufactured Drug</h2>
<form action="/manufactured/create" method="post">
	<input type="text" name="name" value="" placeholder="Name">
	<input type="text" name="manufacturer" value="" placeholder="Manufacturer">
	
	<select name="category">
		<cfset catTypeID = application.categoryTypeLookup['manufactured'].id>
		<cfloop collection="#application.categories[catTypeID].categories#" item="i">
			<cfoutput>
				<option value="#application.categories[catTypeID].categories[i].categoryID#">#application.categories[catTypeID].categories[i].name#</option>
			</cfoutput>
		</cfloop>
	</select>
	<input type="submit" value="Create">
</form>