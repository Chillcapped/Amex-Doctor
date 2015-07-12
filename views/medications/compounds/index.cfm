


<cfoutput>#includePartial("/#lcase(application.roles[session.user.role].name)#/includes/sideMenu")#</cfoutput>

<div id="contentContainer">
	<ul>
		<a href="/pharmacist/createCompound"><li>Create Compound</li></a>
	</ul>
	
	<h4>Compounds</h4>
	<table>
		<thead>
			<tr>
				<th>Compound Name:</th>
				<th>Category</th>
				<th>Available</th>
				<th>Details</th>
			</tr>
		</thead>
		<tbody>
			<cfloop collection="#application.compounds#" item="i">
				<cfoutput>
				<tr>
					<td>#application.compounds[i].name#</td>
					<td>#application.compounds[i].categoryID#</td>
					<td>---</td>
					<td><a href="/compounds/#i#">Details</a></td>
				</tr>
				</cfoutput>
			</cfloop>
		</tbody>
	</table>
</div>