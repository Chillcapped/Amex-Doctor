<cfcomponent extends="Controller">
	
	<!--- Create New Manufactured Drug --->
	<cffunction name="create" access="public" hint="">
		
		<cfif structKeyExists(params, "name")>
			<cfinvoke component="api.medications" method="createManufacturedDrug" returnVariable="newManufacturedDrug">
				<cfinvokeargument name="name" value="#params.name#">
				<cfinvokeargument name="category" value="#params.category#">
				<cfinvokeargument name="manufacturer" value="#params.manufacturer#">
				<cfinvokeargument name="authToken" value="#session.user.authToken#">
				<cfinvokeargument name="returnType" value="struct">
			</cfinvoke>
			
			<cfdump var="#newManufacturedDrug#">
			<cfabort>
			
			
		</cfif>
		
		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/portal_layouts/medications/manufactured/create")>
	</cffunction>
	
	
	<!--- Index --->
	<cffunction name="index">
		
		
		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/portal_layouts/medications/manufactured/index")>
	</cffunction>
	
	
	
	<!--- Manufacturers Page --->
	<cffunction name="manufacturers">
		
		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/portal_layouts/medications/manufactured/manufacturers")>
	</cffunction>
	
	
	
	
	<cffunction name="manufacturedDrugs">
		
	</cffunction>
	
</cfcomponent>