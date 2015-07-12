<cfinvoke component="api.doctor" method="getDoctorsPrescriptions" returnVariable="doctorsRx">
	<cfinvokeargument name="authToken" value="#session.user.authToken#">
	<cfinvokeargument name="filter" value="#application.rxStatus['Expired'].statusID#">
	<cfinvokeargument name="returnType" value="struct">
	<cfinvokeargument name="enc" value="false">
	<cfinvokeargument name="filterBy" value="#application.rxStatus['Expired'].statusID#">
</cfinvoke>


<!--- Prescriptions Expiring Within 60 Days --->
<table class="table">
	<thead>
		<tr>
			<th>Patient Name:</th>
			<th>Prescription:</th>
			<th>Prescribe Date:</th>
			<th>Expires On:</th>
      <th>Renew:</th>
		</tr>
	</thead>
	<tbody>

  </tbody>
</table>
