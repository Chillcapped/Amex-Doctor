<cfcomponent>
	
	<!--- Get pending Invites --->
	<cffunction name="getInvites" access="public" hint="Returns Invites sent by user">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="filterOut" type="string" default="" required="false">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" type="string" default="false">
		
		
		<cfset result = structNew()>
		<cfset result.status = false>
	
		<!--- Get Token Info --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
		
		<!--- If valid token and sales user --->
		<cfif tokenOwner.status and application.roles[tokenOwner.role].name EQ "Sales">
			<cfset result.status = true>
			<cfset result.pending = arrayNew(1)>
			<!--- Get Pending Invites from this User --->
			<cfquery name="getPending" datasource="#application.contentDB#">
				select inviteID, verifyString, inviteCode, email, firstName, middleName, lastName, title,
				inviteDate, redeemed
				from doctors_invites
				where salesRep = <cfqueryparam cfsqltype="cf_sql_integer" value="#tokenOwner.userID#"> 
				<!--- If we are filtering --->
				<cfif len(arguments.filterOut)>
					<cfif arguments.filterOut EQ "redeemed">
						and redeemed = <cfqueryparam cfsqltype="cf_sql_integer" value="0">
					<cfelseif arguments.filterOut EQ "invited">
						and redeemed = <cfqueryparam cfsqltype="cf_sql_integer" value="1">	
					</cfif>
				</cfif>
				order by inviteDate asc
			</cfquery>
			
			<cfloop query="getPending">
				<cfset x = arrayLen(result.pending) + 1>
				<cfset result.pending[x] = structNew()>
				<cfloop list="#getPending.columnList#" index="i">
					<cfset result.pending[x][i] = getPending[i][getPending.currentRow]>
				</cfloop>
			</cfloop>
			
		</cfif>
		
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	
	
	<!--- Get Assigned Doctors --->
	<cffunction name="getAssignedDoctors" access="public" hint="returns a users assigned doctors">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" type="string" default="false">
		
		<cfset result = structNew()>
		<cfset result.status = false>
	
		<!--- Get Token Info --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
		
		<!--- If valid token and sales user --->
		<cfif tokenOwner.status and application.roles[tokenOwner.role].name EQ "Sales">
			<cfset result.status = true>
			<cfset result.doctors = arrayNew(1)>
			
			<cfquery name="getDoctors" datasource="#application.contentDB#">
				select doctorID, email, firstName, middleName, lastName, title, phone
				phoneExt, createDate, verifiedDate
				from doctors
				where salesRep = <cfqueryparam cfsqltype="cf_sql_integer" value="#tokenOwner.userID#"> 
			</cfquery>
			
			<cfloop query="getDoctors">
				<cfset x = arrayLen(result.doctors) + 1>
				<cfset 	result.doctors[x] = structNew()>
				<cfloop list="#getDoctors.columnList#" index="i">
					<cfset result.doctors[x][i] = getDoctors[i][getDoctors.currentRow]>
				</cfloop>
			</cfloop>
		</cfif>
		
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	
</cfcomponent>