<cfcomponent>

	<!--- Event Functions Store Data in My SQL Database but also send to elastic --->

	<!---- Log Doctor Action --->
	<cffunction name="logEvent" access="public" hint="">
		<cfargument name="user" type="struct" required="true">
		<cfargument name="action" type="struct" required="true">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" default="struct">

		<cfset result = structNew()>

		<!--- --->
		<cfset requiredActionList = "description,timestamp,type,typeID">
		<cfset requiredUserList = "userID,userToken,role">

		<cfloop list="#requiredActionList#" index="i">
			<cfif !structKeyExists(arguments.action, i)>
				<cfset result.status = false>
				<cfset result.message = "#i# is Required">
			</cfif>
		</cfloop>

		<!--- Set Type ID to 0 If not Supplied --->
		<cfif !structKeyExists(arguments.action, "typeID")>
			<cfset arguments.action.typeID = 0>
		</cfif>

		<cfif !structKeyExists(result, "status")>
			<cfset result.status = true>
		</cfif>

		<cfif result.status>
			<cfquery name="saveEvent" datasource="#application.internalDB#" result="newEvent">
				insert into events
				(description,timestamp,type,typeID,userID,role,token,ip)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.action.description#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.action.timestamp#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.action.type#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.action.typeID#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.user.userID#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.user.role#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(arguments.authToken)#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.cgi.remote_addr#">
				)
			</cfquery>

			<cfset result.message = "Created Event">

			<!--- Send to Elastic --->
			<cfset elasticData = structNew()>
			<cfset elasticData.description = arguments.action.description>
			<cfset elasticData.eventID = newEvent.generated_key>
			<cfset elasticData.timeStamp = arguments.action.timestamp>
			<cfset elasticData.type = arguments.action.type>
			<cfset elasticData.userID = arguments.user.userID>
			<cfset elasticData.role = arguments.user.role>
			<cfset elasticData.token = hash(arguments.authToken)>
			<cfset elasticData.ip = request.cgi.remote_addr>
			<cfset elasticData.eventGroupID = arguments.action.eventGroupID>


			<!--- Send RX struct to Elastic --->
			<cfinvoke component="miscellaneous.elastic.elastic" method="indexData" returnvariable="indexStatus">
				<cfinvokeargument name="data" value="#elasticData#">
				<cfinvokeargument name="index" value="amex">
				<cfinvokeargument name="table" value="events">
				<cfinvokeargument name="id" value="#newEvent.generated_key#">
			</cfinvoke>


			<cfset result.elasticResponse = indexStatus>
		</cfif>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>



	<!--- Log Failed Login Attempt ---->
	<cffunction name="logFailedLoginAttempt" access="public" returnFormat="plain">
		<cfargument name="email" type="string" required="true">
		<cfargument name="attemptedPassword" type="string" required="true">


		<!---- Save Attempt --->


		<!---- If more than 5 for same account, Send Email Notification --->

	</cffunction>


	<!--- Get User Events --->
	<cffunction name="getUserEvents" access="public" returnFormat="plain">
		<cfargument name="userID" type="numeric" required="true">
		<cfargument name="roleID" type="numeric" required="true">
		<cfargument name="fetchType" type="string" default="elastic">

		<cfset result = structNew()>
		<cfset result.fetchType = arguments.fetchType>

		<!--- If DB Search --->
		<cfif arguments.fetchType EQ "db">

			<cfquery name="getEvents" datasource="#application.internalDB#">
				select * from events
				where userID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#">
				and role = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.roleID#">
			</cfquery>

		<!--- If Elastic Search ---->
		<cfelse>

			<!--- Construct Query --->
			<cfset search = structNew()>
			<cfset search['query'] = structNew()>
			<cfset search['query']['query_string'] = structNew()>
			<cfset search['query']['query_string']['query'] = "*">

			<!--- Hit Rx Search --->
			<cfinvoke component="miscellaneous.elastic.Elastic" method="searchIndex" returnvariable="results">
				<cfinvokeargument name="alias" value="ev:doctor@doctor_com">
				<cfinvokeargument name="q" value="#serializeJson(search)#">
				<cfinvokeargument name="searchType" value="advanced">
				<cfinvokeargument name="returnType" value="struct">
			</cfinvoke>

			<cfset result.events = results.hits.hits>
		</cfif>


		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>


</cfcomponent>
