<div id="header">
	<img id="logo" src="/images/logo.jpg" height="90" width="150">
		<cfoutput>#includePartial("/portal_layouts/doctor/includes/searchContainer")#</cfoutput>
	<ul></ul>
</div>
<cfoutput>#includePartial("/portal_layouts/doctor/includes/sideMenu")#</cfoutput>

<div id="contentContainer">
	<h4>Shipments</h4>
	<table class="table">
		<thead>
			<tr>
				<th>Patient Name</th>
				<th>Active Prescription</th>
				<th>Last Order Date</th>
				<th>Destination</th>
			</tr>
		</thead>
		<tbody>

		</tbody>
	</table>
</div>
