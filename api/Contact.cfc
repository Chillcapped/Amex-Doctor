<cfcomponent>


	<!--- Create Custom Compound Inquiry --->
	<cffunction name="createCustomCompoundInquiry" access="public" hint="">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="enc" type="string" default="true">
		<cfargument name="returnType" type="string" default="json">

		<cfset result = structNew()>
		<cfset result.status = false>

		<!--- Get Token Info --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>

		<!--- If token is Doctor, set doctorID --->
		<cfif application.roles[tokenowner.role].name EQ "doctor">
			<cfset doctorID = tokenOwner.userID>
			<cfset result.status = true>
		<!--- If token is delegate, get doctor ID --->
		<cfelseif application.roles[tokenOwner.role].name EQ "doctor_delegate">
			<cfset doctorID = tokenOwner.doctorID>
			<cfset result.status = true>
		</cfif>

		<cfif result.status>


		</cfif>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>


	<!--- Create new Contact Request --->
	<cffunction name="createNewContactRequest" access="public" hint="">
	 	<cfargument name="authToken" type="string" required="true">
		<cfargument name="enc" type="string" default="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="message" type="string" required="true">


		<cfset result = structNew()>
		<cfset result.status = false>

		<!--- Get Token Info --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>

		<!--- If token is Doctor, set doctorID --->
		<cfif application.roles[tokenowner.role].name EQ "doctor">
			<cfset doctorID = tokenOwner.userID>
			<cfset result.status = true>
		<!--- If token is delegate, get doctor ID --->
		<cfelseif application.roles[tokenOwner.role].name EQ "doctor_delegate">
			<cfset doctorID = tokenOwner.doctorID>
			<cfset result.status = true>
		</cfif>

		<cfif !len(message) Gt 5>
			<cfset result.status = false>
			<cfset result.message = "Message Must be longer than 5 characters">
		</cfif>


		<cfif result.status>
			<!--- Insert Contact Request --->
			<cfquery name="insertContactRequest" datasource="#application.internalDB#" result="newContact">
				insert into contacts_general
				(doctorID,message,timestamp,status,ip,sentBy)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_integer" value="#doctorID#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.message#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="1">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.cgi.remote_addr#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#tokenOwner.userID#">
				)
			</cfquery>

			<!--- Send Contact Request to Elastic --->
			<cfset contact = structNew()>
			<cfset contact.contactID = newContact.generated_key>
			<cfset contact.message = arguments.message>
			<cfset contact.timestamp = now()>
			<cfset contact.status = 1>
			<cfset contact.ip = request.cgi.remote_addr>
			<cfset contact.sentBy = tokenOwner.userId>

			<cfinvoke component="miscellaneous.elastic.elastic" method="indexData" returnvariable="indexStatus">
				<cfinvokeargument name="data" value="#contact#">
				<cfinvokeargument name="index" value="amex">
				<cfinvokeargument name="table" value="contactRequest">
				<cfinvokeargument name="id" value="#newContact.generated_key#">
			</cfinvoke>

			<cfset result.message = "Created Contact Request">

		</cfif>


		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>


	</cffunction>


</cfcomponent>
