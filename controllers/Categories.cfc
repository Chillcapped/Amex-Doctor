<cfcomponent extends="Controller">

	<!--- Create Category Type --->
	<cffunction name="createType">
		<cfif structKeyExists(params, "name")>
			<cfif len(params.name) EQ 0>
				<cfset params.message = "Name is required">
			<cfelse>
				
				<cfinvoke component="api.medications" method="createCategoryType" returnVariable="createdCategory">
					<cfinvokeargument name="name" value="#params.name#">
					<cfinvokeargument name="authToken" value="#session.user.authToken#">
					<cfinvokeargument name="enc" value="false">
					<cfinvokeargument name="returnType" value="struct">
				</cfinvoke>
				
				
				<cfset params.message = createdCategory.message>
			</cfif>
		</cfif>
		
		<Cfset renderPage(template="createType.cfm")>
	</cffunction>
	
	
	<!--- Create Category --->
	<cffunction name="createCategory">
		<cfset errors = arrayNew(1)>
		<cfset requiredCols = "type,name">
		
		<cfloop list="#requiredCols#" index="i">
			<cfif !structKeyExists(params, i) or structKeyExists(params, i) and len(params[i]) EQ 0>
				<cfset errors[arrayLen(errors) + 1] = structNew()>
				<cfset errors[arrayLen(errors)].message = "#i# is required">
			</cfif>
		</cfloop>	
		
		<!--- If we have form data, send to api --->
		<cfif !arrayLen(errors)>
			<cfinvoke component="api.medications" method="createCategory" returnVariable="createdCategory">
				<cfinvokeargument name="name" value="#params.name#">
				<cfinvokeargument name="type" value="#params.type#">
				<cfinvokeargument name="authToken" value="#session.user.authToken#">
				<cfinvokeargument name="enc" value="false">
				<cfinvokeargument name="returnType" value="struct">
			</cfinvoke>
			
			
		</cfif>
	</cffunction>
	
</cfcomponent>