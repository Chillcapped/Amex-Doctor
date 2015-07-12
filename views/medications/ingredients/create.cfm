<h4>Create Ingredient</h4>

<cfloop collection="#application.categories#" item="i">
	<cfif application.categories[i].name EQ "ingredient" or application.categories[i].name EQ "ingredients">
		<cfset params.categoryID = i>
		<cfbreak>
	</cfif>
</cfloop>

<form action="/ingredients/create" method="post">
	<label>Name:</label>
	<input type="text" name="name" value="" placeholder="Name">	
	<label>Category:</label>
	<select name="category">
		<cfloop collection="#application.categories[params.categoryID].categories#" item="i">
			<cfoutput>
			<option value="#i#">#application.categories[params.categoryID].categories[i].name#</option>
			</cfoutput>
		</cfloop>
	</select>
	<input type="submit" value="Add">
</form>

<!---
<cfdump var="#application.categories[params.categoryID].categories#">
<cfdump var="#params#">

--->