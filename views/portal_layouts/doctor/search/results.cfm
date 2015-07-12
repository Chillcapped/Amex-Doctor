

<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/pageHeader")#</cfoutput>
<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/sideMenu")#</cfoutput>


<!--- Hit Doctor Search --->
<cfinvoke component="miscellaneous.elastic.Elastic" method="searchIndex" returnvariable="results">
	<cfinvokeargument name="index" value="pr:doctor@doctor_com,rx:doctor@doctor_com">
	<cfinvokeargument name="q" value="#params.q#">
	<cfinvokeargument name="searchType" value="basic">
	<cfinvokeargument name="returnType" value="struct">
</cfinvoke>

<!--- Get Scroll Data for This Page --->
<cfinvoke component="miscellaneous.elastic.Elastic" method="getScrollData" returnvariable="scrollData">
	<cfinvokeargument name="scrollID" value="#results['_scroll_id']#">
	<cfinvokeargument name="scrollTimeout" value="1">
	<cfinvokeargument name="returnType" value="struct">
</cfinvoke>

<div id="contentContainer">
	<h4>Search Results</h4>
	<div id="searchResultsContainer">
		<table class="table">
			<thead>
				<th>Type</th>
				<th>Number</th>
				<th>Patient</th>
				<th>View</th>
			</thead>
			<tbody>
				<!--- --->
				<cfloop from="1" to="#arrayLen(scrollData.hits.hits)#" index="i">
					<cfoutput>
						<cfif scrollData.hits.hits[i]['_type'] EQ "patients">
						<tr>
							<td>Patient</td>
							<td>-</td>

							<td>#scrollData.hits.hits[i]['_source']['FIRSTNAME']# #scrollData.hits.hits[i]['_source']['MIDDLENAME']# #scrollData.hits.hits[i]['_source']['LASTNAME']#</td>
							<td><a href="">View</a></td>
						</tr>
						<cfelseif  scrollData.hits.hits[i]['_type'] EQ "prescriptions">
						<tr>
							<td>Prescription</td>
							<td>#scrollData.hits.hits[i]['_source']['RXID']#</td>

							<td>#scrollData.hits.hits[i]['_source']['FIRSTNAME']# #scrollData.hits.hits[i]['_source']['MIDDLENAME']# #scrollData.hits.hits[i]['_source']['LASTNAME']#</td>
							<td><a href="">View</a></td>
						</tr>
						</cfif>
					</cfoutput>
				</cfloop>

			</tbody>
		</table>

	</div>


</div>
