

<!--- Get Event History --->
<cfinvoke component="api.events" method="getUserEvents" returnvariable="results">
	<cfinvokeargument name="userID" value="#session.user.userID#">
	<cfinvokeargument name="roleID" value="#session.user.roleID#">
	<cfinvokeargument name="returnType" value="struct">
</cfinvoke>


<table class="table">
	<thead>
		<tr>
			<th>Time</th>
			<th>Action</th>
			<th style="width:50%">Description</th>
			<th>Event Type</th>
		</tr>
	</thead>
	<tbody>
		<cfloop from="1" to="#arrayLen(results.events)#" index="i">
		<tr>
			<cfoutput>
			<td>#dateFormat(results.events[i]['_source']['TIMESTAMP'])# #timeFormat(results.events[i]['_source']['TIMESTAMP'])#</td>

			<td>#application.eventTypes[application.eventTypeLookup[results.events[i]['_source']['TYPE']].name].name#</td>
			<td>#results.events[i]['_source']['DESCRIPTION']#</td>
			<td>#application.eventTypes[application.eventTypeLookup[results.events[i]['_source']['TYPE']].name].eventGroupName#</td>
			</cfoutput>
		</tr>
		</cfloop>
	</tbody>
</table>
