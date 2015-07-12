
<cfoutput>#includePartial("/portal_layouts/pharmacist/includes/sideMenu")#</cfoutput>

<div id="contentContainer">
	<h4>Ingredients</h4>
	<p>Globally Available Ingredients are listed below</p>
	
	<a href="/pharmacist/addIngredient">Add Ingredient</a>
	
	<table>
		<thead>
			<tr>
				<th>Ingredient Name:</th>
				<th>Category</th>
				<th>Available</th>
				<th>Details</th>
			</tr>
		</thead>
		<tbody>
			<cfloop collection="#application.ingredients#" item="i">
				<cfoutput>
				<tr>
					<td>#application.ingredients[i].name#</td>
					<td>#application.ingredients[i].categoryID#</td>
					<td>---</td>
					<td><a href="/ingredients/#i#">Details</a></td>
				</tr>
				</cfoutput>
			</cfloop>
		</tbody>
	</table>
</div>