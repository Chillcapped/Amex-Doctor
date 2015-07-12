<cfinvoke component="api.doctor" method="getPatients" returnVariable="patientLookup">
	<cfinvokeargument name="doctorID" value="#session.user.userID#">
	<cfinvokeargument name="authToken" value="#session.user.authToken#">
	<cfinvokeargument name="returnType" value="struct">
	<cfinvokeargument name="enc" value="false">
</cfinvoke>

<h4>Patients</h4>
<table>
	<thead>
		<tr>
			<th>First Name</th>
			<th>Middle Name</th>
			<th>Last Name</th>
			<th>Phone Number</th>
			<th>Last Script Date</th>
			<th>Last Script #</th>
		</tr>
	</thead>
	<tbody>
		<cfloop from="1" to="#arrayLen(patientLookup.patients)#" index="i">
			<cfoutput>
			<tr>
				<td>#patientLookup.patients[i].firstName#</td>
				<td>#patientLookup.patients[i].middleName#</td>
				<td>#patientLookup.patients[i].lastName#</td>
				<td>#patientLookup.patients[i].homePhone#</td>
				<td>-</td>
				<td>-</td>
			</tr>
			</cfoutput>
		</cfloop>
	</tbody>
</table>