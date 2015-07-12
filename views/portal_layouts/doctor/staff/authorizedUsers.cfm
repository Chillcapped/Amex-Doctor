
<div id="header">
	<img id="logo" src="/images/logo.jpg" height="90" width="150">
	<cfoutput>#includePartial("/portal_layouts/doctor/includes/searchContainer")#</cfoutput>
	<ul>
		<a href="javascript:showNewAuthorizedUser();" id="addNewAuthorizedUser"><li class="fullBtn">Add Authorized User</li></a>
	</ul>
</div>

<cfoutput>#includePartial("/portal_layouts/doctor/includes/sideMenu")#</cfoutput>
<div id="contentContainer">
<h4>Authorized Users</h4>


<div class="clear">
<p>Manage your authorized users below</p>

</div>
<!--- If we have Authorized Users --->
<cfif arrayLen(staffLookup.delegates)>
	<table class="table">
		<thead>
			<tr>
				<th>First Name</th>
				<th>Last Name</th>
				<th>Email</th>
				<th>Job Role</th>
				<th>Active</th>
				<th>Reset Password</th>
				<th>Edit</th>
				<th>Remove Access</th>
			</tr>
		</thead>
		<tbody>
		<cfloop from="1" to="#arrayLen(staffLookup.delegates)#" index="i">
			<cfoutput>
				<tr>
					<td>#staffLookup.delegates[i].firstName#</td>
					<td>#staffLookup.delegates[i].lastName#</td>
					<td>#staffLookup.delegates[i].email#</td>
					<td>#staffLookup.delegates[i].jobRole#</td>
					<td><input type="checkbox" name="delegate#i#" value="true"></td>
					<td><a href="">Reset</a></td>
					<td><a href="">Edit</a></td>
					<td><a href="">Remove</a></td>
				</tr>
			</cfoutput>
		</cfloop>
		</tbody>
	</table>
	
<cfelse>
	<h4>No Current Authorized Users </h4>
	
</cfif>
</div>