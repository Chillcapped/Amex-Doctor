<cfcomponent>

	<!--- Runs on Application Start --->
	<cffunction name="initialize" access="remote">
		<cfset application.elastic = structNew()>
		<cfset application.elastic.index = structNew()>
		<cfset application.elastic.table = structNew()>

		<cfset application.elastic.PROTOCOL = "https://">
		<cfset application.elastic.URL = "esproxy">
		<cfset application.elastic.PORT = "553">
		<cfset application.elastic.rawURL = "#application.elastic.protocol##application.elastic.url#:#application.elastic.port#">

		<!--- If we are using elastic shield for authorization --->
		<cfset application.elastic.shield = structNew()>
		<cfset application.elastic.shield.enabled = true>
		<cfset application.elastic.shield.username = "mf">
		<cfset application.elastic.shield.password = "mf!survivor">
		<cfset application.elastic.shield.serverToken = tobase64("#application.elastic.shield.username#:#application.elastic.shield.password#")>
		<cfset application.elastic.URL = "#application.elastic.rawURL#/#application.elastic.shield.serverToken#/es/">

		<cfreturn true>
	</cffunction>


	<!--- Check if Elastic is Running --->
	<cffunction name="isRunning" access="public" hint="Returns boolean if Elastic is currently running" >
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="returnType" default="json" type="string">

		<cfhttp method="get" url="#arguments.serverAddress#/" result="ping" />

		<cfif structKeyExists(deserializeJson(ping.filecontent), "version")>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>


	<!--- Get index Stats --->
	<cffunction name="getIndexStatus" access="public" hint="Returns Stats about an Index">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="index" required="true" type="string">
		<cfargument name="returnType" default="json" type="string">

		<cfhttp method="get" url="#arguments.serverAddress#/#arguments.index#/_status"
		result="status" />

		<cfif arguments.returnType EQ "json">
			<cfreturn status.fileContent>
		<Cfelse>
			<cfreturn deserializeJson(status.fileContent)>
		</cfif>
	</cffunction>


	<!--- Index Data --->
	<cffunction name="indexData" access="public" hint="sends a data object to elastic search for indexing">
		<cfargument name="serverAddress" default="#application.elastic.rawURL#" type="string">
		<cfargument name="index" required="true" type="string">
		<cfargument name="table" default="" type="string">
		<cfargument name="data" required="true" type="struct">
		<cfargument name="id" required="true" type="numeric">
		<cfargument name="returnType" default="json" type="string">

		<cfset esUser64 = tobase64('#replace(session.user.email, ".", "_", "all")#:#session.user.esToken#')>

		<cfset variables.serverUrl = "#arguments.serverAddress#/#esUser64#/es/#arguments.index#/#arguments.table#">

		<cfhttp method="post" url="#variables.serverURL#/#arguments.id#/" result="indexStatus">
			<cfhttpparam  type="body" value="#serializeJson(arguments.data)#">
		</cfhttp>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(indexStatus)>
		<cfelse>
			<cfreturn indexStatus>
		</cfif>
	</cffunction>


	<!--- Create Index --->
	<cffunction name="createIndexDatabase" access="public" hint="Creates an Elastic Search Database Index">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="index" required="true" type="string" hint="Name of Index to Create">
		<cfargument name="numShards" default="2" type="numeric" hint="Number of Shards for Index">
		<cfargument name="replicas" default="1" type="numeric" hint="Number of Replicas of Index">
		<cfargument name="settings" required="true" type="struct" hint="Structure of Index Settings">
		<cfargument name="returnType" default="json" type="string">

		<cfset settings = structCopy(arguments.settings)>
		<cfset settings.index = structNew()>
		<cfset settings.index["number_of_shards"] = arguments.numShards>
		<cfset settings.index["number_of_replicas"] = arguments.replicas>

		<cfhttp method="get" url="#arguments.serverAddress#/#arguments.index#/" result="indexStatus">
			<cfhttpparam  type="body" value="#serializeJson(settings)#">
		</cfhttp>

		<cfreturn indexStatus>
	</cffunction>


	<!--- Get Index Contents --->
	<cffunction name="getIndexContents" access="public" hint="Returns Contents of an elastic Index">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="index" required="true" type="string">
		<cfargument name="items" default="0" type="numeric">
		<cfargument name="returnType" default="json" type="string">

		<cfif arguments.items EQ 0>
			<cfset arguments.items = 10000>
		</cfif>
		<cfset result = structNew()>
		<cfset result.query = structNew()>
		<cfset result.query["match_all"] = structNew()>

		<cfhttp method="get" url="#arguments.serverAddress#/#arguments.index#/_search?&size=#arguments.items#" result="index">
			<cfhttpparam  type="body" value="#serializeJson(result)#">
		</cfhttp>
		<cfset scrollStruct = deserializeJson(index.fileContent)>
	</cffunction>


	<!--- Get Data from Scroll ID --->
	<cffunction name="getScrollData" access="public" hint="Returns Data from an Elastic Scroll ID">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="scrollID" type="string" required="true">
		<cfargument name="scrollTimeout" type="numeric" default="5" hint="Timeout of Elastics inner scrolling for this search. [Ms]">
		<cfargument name="returnType" default="json" type="string">

		<cfhttp method="get" url="#arguments.serverAddress#/_search/scroll?scroll=#arguments.scrollTimeout#m&scroll_id=#arguments.scrollID#" result="scrollData" />


		<cfif arguments.returnType EQ "json">
			<cfreturn scrollData.fileContent>
		<cfelse>
			<cfreturn deserializeJson(scrollData.fileContent)>
		</cfif>
	</cffunction>



	<!--- Search index --->
	<cffunction name="searchIndex" access="public" hint="Returns Data from index">
		<cfargument name="serverAddress" default="#application.elastic.rawURL#" type="string">
		<cfargument name="index" default="" type="string">
		<cfargument name="alias" default="" type="string">
		<cfargument name="table" default="" type="string">
		<cfargument name="startItem" default="1" type="numeric">
		<cfargument name="endItem" default="10" tyoe="numeric">
		<cfargument name="searchType" default="basic" type="string">
		<cfargument name="returnType" default="json" type="string">
		<cfargument name="q" required="true">


		<cfset esUser64 = tobase64('#replace(session.user.email, ".", "_", "all")#:#session.user.esToken#')>

		<cfif len(index) and len(table)>
			<cfset variables.serverUrl = "#arguments.serverAddress#/#esUser64#/es/#arguments.index#/#arguments.table#">
		<cfelseif len(index)>
			<cfset variables.serverUrl = "#arguments.serverAddress#/#esUser64#/es/#arguments.index#">
		<cfelseif len(alias)>
			<cfset variables.serverUrl = "#arguments.serverAddress#/#esUser64#/es/#arguments.alias#">
		<cfelse>
			<cfset variables.serverUrl = arguments.serverAddress>
		</cfif>


		<!--- If Basic Search Type --->
		<cfif arguments.searchType EQ "basic">
			<!--- Search Elastic --->
			<cfhttp method="get" url="#variables.serverUrl#/_search/?q=#arguments.q#&search_type=scan&scroll=10m&size=10" result="searchResults" />

		<!--- If Advanced Search --->
		<cfelse>
			<cfif arguments.alias EQ "">
			<!--- Build Query Json Struct --->
			<cfhttp method="post"
				url="#variables.serverUrl#/_search?&search_type=scan&scroll=1m&size=10"
				result="searchResults" charset="utf-8">
				<cfhttpparam type="body" value="#arguments.q#">
				<cfhttpparam type="header" name="Content-Length" value="#len(arguments.q)#">
				<cfhttpparam type="HEADER" name="Keep-Alive" value="300">
				<cfhttpparam type="HEADER" name="Connection" value="keep-alive">
				<cfhttpparam type="header" name="Content-Type" value="application/json; charset=utf-8" />
			</cfhttp>


			<!--- If Searching By Alias --->
			<cfelse>

				<cfif arguments.q EQ "">
					<cfhttp method="get"
						url="#variables.serverUrl#/_search/?q=*"
						result="searchResults" charset="utf-8" />
				<cfelse>
					<cfhttp method="post"
						url="#variables.serverUrl#/_search?&search_type=scan&scroll=1m&size=10"
						result="searchResults" charset="utf-8">
						<cfhttpparam type="body" value="#arguments.q#">
						<cfhttpparam type="header" name="Content-Length" value="#len(arguments.q)#">
						<cfhttpparam type="HEADER" name="Keep-Alive" value="300">
						<cfhttpparam type="HEADER" name="Connection" value="keep-alive">
						<cfhttpparam type="header" name="Content-Type" value="application/json; charset=utf-8" />
					</cfhttp>
				</cfif>


			</cfif>
		</cfif>


		<cfif arguments.returnType EQ "json">
			<cfreturn searchResults.fileContent>
		<cfelse>
			<cfreturn deserializeJson(searchResults.fileContent)>
		</cfif>

	</cffunction>



	<!--- ReMap Index --->
	<cffunction name="reMapIndex" access="public" hint="Remaps an index from supplied Mapping Struct">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="index" default="" type="string">
		<cfargument name="newMapData" type="struct" required="true">
		<cfargument name="returnType" default="json" type="string">

		<!--- Delete Index --->
		<cfinvoke component="elastic" method="deleteIndex" returnvariable="deletedDatabase">
			<cfinvokeargument name="index" value="#arguments.index#">
		</cfinvoke>

		<!--- Create Database --->
		<cfinvoke component="elastic" method="createIndexDatabase" returnvariable="createdDatabase">
			<cfinvokeargument name="index" value="#arguments.index#">
			<cfinvokeargument name="settings" value="#arguments.newMapData#">
		</cfinvoke>
	</cffunction>


	<!--- Update Index Item --->
	<cffunction name="updateIndexItem" access="public" hint="Submits a partial Update to an index item">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="index" required="true" type="string">
		<cfargument name="table" default="" type="string">
		<cfargument name="itemID" required="true" type="numeric">
		<cfargument name="updatedItemData" required="true" type="struct">
		<cfargument name="returnType" default="json" type="string">

		<cfif len(index) and len(table)>
			<cfset variables.serverUrl = "#arguments.serverAddress#/#arguments.index#/#arguments.table#">
		<cfelseif len(index)>
			<cfset variables.serverUrl = "#arguments.serverAddress#/#arguments.index#">
		<cfelse>
			<cfset variables.serverUrl = arguments.serverAddress>
		</cfif>

		<cfset result = structNew()>
		<cfset result.doc = structCopy(arguments.updatedItemData)>

		<!--- Send Update Packet --->
		<cfhttp method="post" url="#variables.serverUrl#/#arguments.itemID#/_update?retry_on_conflict=5" result="updateResults">
			<cfhttpparam type="body" value="#serializeJson(result)#">
		</cfhttp>

		<cfif arguments.returnType EQ "json">
			<cfreturn updateResults.fileContent>
		<Cfelse>
			<cfreturn deserializeJson(updateResults.fileContent)>
		</cfif>
	</cffunction>


	<!--- Delete Index --->
	<cffunction name="deleteIndex" access="public" hint="Removes an index from elastic">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="index" required="true" type="string">
		<cfargument name="table" default="" type="string">
		<cfargument name="returnType" default="json" type="string">

		<cfif len(arguments.table) and len(arguments.index)>
			<cfhttp method="delete" url="#arguments.serverAddress#/#arguments.index#/#arguments.table#"  result="deleteResults">
		<cfelse>
			<cfhttp method="delete" url="#arguments.serverAddress#/#arguments.index#"  result="deleteResults">
		</cfif>

		<cfif arguments.returnType EQ "json">
			<cfreturn deleteResults.fileContent>
		<Cfelse>
			<cfreturn deserializeJson(deleteResults.fileContent)>
		</cfif>
	</cffunction>


	<!--- Get Current Indexes --->
	<cffunction name="getCurrentIndexes" access="public" hint="Get Current Indexes in Elastic Search">
		<cfargument name="serverAddress" default="#application.elastic.rawURL#" type="string">
		<cfargument name="returnType" default="json" type="string">


		<cfset esUser64 = tobase64('#replace(session.user.email, ".", "_", "all")#:#session.user.esToken#')>

		<cfset variables.serverUrl = "#arguments.serverAddress#/#esUser64#/es/_status">

		<cfhttp method="get" url="#variables.serverUrl#" result="status" />

		<cfif arguments.returnType EQ "json">
			<cfreturn status.fileContent>
		<Cfelse>
			<cfreturn deserializeJson(status.fileContent)>
		</cfif>
	</cffunction>


	<!--- Get Index Settings --->
	<cffunction name="getIndexSettings" access="public">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="returnType" default="json" type="string">
		<cfargument name="index" required="true" type="string">

		<cfset esUser64 = tobase64('#replace(session.user.email, ".", "_", "all")#:#session.user.esToken#')>

		<cfif len(index) and len(table)>
			<cfset variables.serverUrl = "#arguments.serverAddress#/#esUser64#/es/#arguments.index#/#arguments.table#">
		<cfelseif len(index)>
			<cfset variables.serverUrl = "#arguments.serverAddress#/#esUser64#/es/#arguments.index#">
		<cfelse>
			<cfset variables.serverUrl = arguments.serverAddress>
		</cfif>

		<cfhttp method="get" url="#variables.serverUrl#/#arguments.index#/_status" result="settings" />



		<cfif arguments.returnType EQ "json">
			<cfreturn settings.fileContent>
		<Cfelse>
			<cfreturn deserializeJson(settings.fileContent)>
		</cfif>
	</cffunction>


	<!--- Get Mappings for Index --->
	<cffunction name="getIndexMappings" access="public">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="returnType" default="json" type="string">
		<cfargument name="index" required="true" type="string">
		<cfargument name="table" default="" type="string">

		<cfhttp method="get" url="#arguments.serverAddress#/#arguments.index#/_mapping/#arguments.table#" result="mapping" />

		<cfif arguments.returnType EQ "json">
			<cfreturn mapping.fileContent>
		<Cfelse>
			<cfreturn deserializeJson(mapping.fileContent)>
		</cfif>
	</cffunction>

</cfcomponent>
