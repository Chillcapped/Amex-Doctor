<cfparam name="params.tab" default="patients">



<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/pageHeader")#</cfoutput>
<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/sideMenu")#</cfoutput>


<div id="dashContainer">
<div id="dashTop">
	<h3>Dashboard</h3>
		<div id="dashTopTiles">
			<ul>
				<a href="/messages"><li>
					<span>Messages</span>
					<font>0</font></li></a>
					<a href="/prescriptions/browse"><li>
					<span>Active Rx</span>
					<font>0</font>
				</li></a>
				<a href="/prescriptions/browse"><li>
					<span>Inactive Rx</span>
					<font>0</font>
				</li></a>
				<a href="/shipments"><li>
					<span>In Transit</span>
					<font>0</font>
				</li></a>
			</ul>
		</div>
		<div id="dashActionBtns">
			<ul>
		  	<a href="javascript:showCreatePatient();"><li class="fullBtn">Add Patient</li></a>
				<a href="/prescribe"><li class="fullBtn">Prescribe</li></a>
				<a href="/order"><li class="fullBtn">Order</li></a>
			</ul>
		</div>
	</div>
	<div id="dashBtm">
		<h3>Recent Events</h3>
		<table class="table">
			<thead>
				<tr>
					<th style="width:100px;">Type</th>
					<th>Description</th>
					<th>Date</th>
					<th>View</th>
				</tr>
			</thead>
			<tbody>
				<cfloop from="1" to="10" index="i">
					<cfoutput>
						<tr>
							<td>RX</td>
							<td>Created Rx: 15#i#</td>
							<td>#timeFormat(now())# #dateFormat(now())#</td>
							<td>View</td>
						</tr>
					</cfoutput>
				</cfloop>
			</tbody>
		</table>
	</div>


</div>
