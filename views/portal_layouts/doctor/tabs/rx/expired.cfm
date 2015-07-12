<cfinvoke component="api.doctor" method="getDoctorsPrescriptions" returnVariable="doctorsRx">
	<cfinvokeargument name="authToken" value="#session.user.authToken#">
	<cfinvokeargument name="filter" value="#application.rxStatus['Expired'].statusID#">
	<cfinvokeargument name="returnType" value="struct">
	<cfinvokeargument name="enc" value="false">
	<cfinvokeargument name="filterBy" value="#application.rxStatus['Expired'].statusID#">
</cfinvoke>


<table class="table">
	<thead>
		<tr>
			<th>Written Date:</th>
			<th>Patient Name:</th>
			<th>Status:</th>
			<th>Expired On: </th>
			<th>Rx:</th>
			<th>Renew:</th>
		</tr>
		<tbody>
			<cfif doctorsRx.method EQ "db">
			<cfloop from="1" to="#arrayLen(doctorsRx.prescriptions)#" index="i">
				<cfoutput>
				<tr>
					<td><a href="javascript:showPrescriptionInfo('#doctorsRx.prescriptions[i].erxID#');">#dateFormat(doctorsRx.prescriptions[i].CREATEDATE, "mm/dd/yyyy")#</a></td>
					<td><a href="javascript:showPrescriptionInfo('#doctorsRx.prescriptions[i].erxID#');">#doctorsRx.prescriptions[i].FirstName# #doctorsRx.prescriptions[i].lastName#</a></td>
					<td><a href="javascript:showAuthorization('#doctorsRx.prescriptions[i].erxID#');">#application.rxStatusIDLookup[doctorsRx.prescriptions[i].status].name#</a></td>
					<td>#dateFormat(createDate(year(now()), month(now()), day(now())))#</td>
					<td><a href="javascript:showPrescriptionInfo('#doctorsRx.prescriptions[i].erxID#');">#doctorsRx.prescriptions[i].homephone#</a></td>
					<td><a href="javascript:showPrescriptionInfo('#doctorsRx.prescriptions[i].erxID#');">#doctorsRx.prescriptions[i].numItems#</a></td>
				</tr>
				</cfoutput>
			</cfloop>
			<cfelse>
				<cfloop from="1" to="#arrayLen(doctorsRx.prescriptions)#" index="i">
					<cfinvoke component="api.encryption" method="encryptFormID" returnVariable="eRx">
						<cfinvokeargument name="id" value="#doctorsRx.prescriptions[i]['_source'].rxID#">
					</cfinvoke>
					<cfoutput>
					<tr>
						<td><a href="javascript:showPrescriptionInfo('#eRx#');">#dateFormat(doctorsRx.prescriptions[i]['_source'].CREATEDATE, "mm/dd/yyyy")#</a></td>
						<td><a href="javascript:showPrescriptionInfo('#eRx#');">#doctorsRx.prescriptions[i]['_source'].FirstName# #doctorsRx.prescriptions[i]['_source'].lastName#</a></td>
						<td><a href="javascript:showPrescriptionInfo('#eRx#');">#application.rxStatusIDLookup[doctorsRx.prescriptions[i]['_source'].status].name#</a></td>
						<td>#dateFormat(createDate(year(now()), month(now()), day(now())))#</td>
						<td><a href="javascript:showPrescriptionInfo('#eRx#');">View</a></td>
						<td><a href="javascript:showPrescriptionInfo('#eRx#');">Renew</a></td>
					</tr>
					</cfoutput>
				</cfloop>

			</cfif>

		</tbody>
	</thead>
</table>
