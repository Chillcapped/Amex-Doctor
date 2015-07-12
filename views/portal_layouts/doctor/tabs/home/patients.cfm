



<cfinvoke component="api.doctor" method="getPatients" returnVariable="patientLookup">
	<cfinvokeargument name="doctorID" value="#session.user.userID#">
	<cfinvokeargument name="authToken" value="#session.user.authToken#">
	<cfinvokeargument name="returnType" value="struct">
	<cfinvokeargument name="enc" value="false">
</cfinvoke>


<table class="table">
	<thead>
		<tr>
			<th>First Name</th>
			<th>Last Name</th>
			<th>DOB</th>
			<th>Phone Number</th>
			<th>Last Script Date</th>
			<th>Last Script #</th>
		</tr>
	</thead>
	<tbody>
		<cfif patientLookup.method EQ "db">
			<cfloop from="1" to="#arrayLen(patientLookup.patients)#" index="i">
				<cfoutput>
				<tr>

						<td><a href="javascript:showPatientInfo('#patientLookup.patients[i].epatientID#');">#patientLookup.patients[i].firstName# </a></td>
						<td><a href="javascript:showPatientInfo('#patientLookup.patients[i].epatientID#');">#patientLookup.patients[i].lastName#</a></td>
						<td><a href="javascript:showPatientInfo('#patientLookup.patients[i].epatientID#');">#dateFormat(patientLookup.patients[i].dob_full, "mm-dd-yyyy")#</a></td>
						<td><a href="tel:#patientLookup.patients[i].homePhone#">#patientLookup.patients[i].homePhone#</a></td>

					<td>&nbsp;</td>
					<td>&nbsp;</td>
				</tr>
				</cfoutput>
			</cfloop>
		<cfelse>


			<cfloop from="1" to="#arrayLen(patientLookup.patients)#" index="i">


				<cfinvoke component="api.encryption" method="encryptFormID" returnVariable="ePatientID">
					<cfinvokeargument name="id" value="#patientLookup.patients[i]['_source'].patientID#">
				</cfinvoke>

				<cfoutput>
				<tr>
				<td><a href="javascript:showPatientInfo('#ePatientID#');">#patientLookup.patients[i]['_source'].firstName# </a></td>
				<td><a href="javascript:showPatientInfo('#ePatientID#');">#patientLookup.patients[i]['_source'].lastName#</a></td>
				<td><a href="javascript:showPatientInfo('#ePatientID#');">#dateFormat(patientLookup.patients[i]['_source'].dob_full, "mm-dd-yyyy")#</a></td>
				<td><a href="tel:#patientLookup.patients[i]['_source'].homePhone#">#patientLookup.patients[i]['_source'].homePhone#</a></td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				</tr>
				</cfoutput>
			</cfloop>
		</cfif>
	</tbody>
</table>
