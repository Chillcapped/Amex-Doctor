<cfcomponent extends="controller">

	<cffunction name="index">
		<cfset renderPage( hideDebugInformation="yes")>
	</cffunction>


	<!--- Bulk Order Select --->
	<cffunction name="bulk">

		<!--- Get patients --->
		<cfinvoke component="api.doctor" method="getPatients" returnVariable="patientLookup">
			<cfinvokeargument name="doctorID" value="#session.user.userID#">
			<cfinvokeargument name="authToken" value="#session.user.authToken#">
			<cfinvokeargument name="returnType" value="struct">
			<cfinvokeargument name="enc" value="false">
		</cfinvoke>


		<cfset renderPage( hideDebugInformation="yes")>
	</cffunction>


	<!--- Bulk Order Preview --->
	<cffunction name="bulkPreview">

		<!--- Get patients --->
		<cfinvoke component="api.doctor" method="getPatients" returnVariable="patientLookup">
			<cfinvokeargument name="doctorID" value="#session.user.userID#">
			<cfinvokeargument name="authToken" value="#session.user.authToken#">
			<cfinvokeargument name="returnType" value="struct">
			<cfinvokeargument name="enc" value="false">
		</cfinvoke>

		<!--- Create List of patients --->
		<cfset ptList = "">
		<cfloop list="#structKeyList(form)#" index="i">
				<cfif left(i, 3) EQ "PT:">
					<cftry>
					<cfset ptID = right(i, len(i) - 3)>
					<cfset ptList = listAppend(ptList, ptID)>
					<cfcatch>

					</cfcatch>
					</cftry>
				</cfif>
		</cfloop>



		<cfset renderPage( hideDebugInformation="yes")>
	</cffunction>

	<!--- Bulk Order Shipping --->
	<cffunction name="bulkShipping">

		<!--- Get patients --->
		<cfinvoke component="api.doctor" method="getPatients" returnVariable="patientLookup">
			<cfinvokeargument name="doctorID" value="#session.user.userID#">
			<cfinvokeargument name="authToken" value="#session.user.authToken#">
			<cfinvokeargument name="returnType" value="struct">
			<cfinvokeargument name="enc" value="false">
		</cfinvoke>

		<!--- Create List of patients --->
		<cfset ptList = "">
		<cfloop list="#structKeyList(form)#" index="i">
				<cfif left(i, 3) EQ "PT:">
					<cftry>
					<cfset ptID = right(i, len(i) - 3)>
					<cfset ptList = listAppend(ptList, ptID)>
					<cfcatch>

					</cfcatch>
					</cftry>
				</cfif>
		</cfloop>



		<cfset renderPage( hideDebugInformation="yes")>
	</cffunction>


</cfcomponent>
