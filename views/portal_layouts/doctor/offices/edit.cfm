<h4>Current Offices</h4>

<cfif arrayLen(officeLookUp.offices) GT 0>
<ul>
	<li>Offices</li>
	<li>Offices Pending</li>
</ul>

<table>
	<thead>
		<tr>
			<th>Office Name:</th>
			<th>City:</th>
			<th>State:</th>
			<th>Address:</th>
			<th>Phone</th>
		</tr>
	</thead>
	<tbody>
		<cfloop from="1" to="#arrayLen(officeLookUp.offices)#" index="i">
			<cfoutput>
			<tr>
				<td>#officeLookUp.offices[i].name#</td>
				<td>#officeLookUp.offices[i].city#</td>
				<td>#officeLookUp.offices[i].state#</td>
				<td>#officeLookUp.offices[i].adddress1# #officeLookUp.offices[i].address2#</td>
				<td>#officeLookUp.offices[i].phone#</td>
			</tr>
			</cfoutput>
		</cfloop>
	</tbody>
</table>
<cfelse>
	<p>You have no Office Locations saved</p>
	<ul>
		<a href="/offices/add"><li class="fullBtn addOfficeBtn">Add Office Location</li></a>
	</ul>
</cfif>
