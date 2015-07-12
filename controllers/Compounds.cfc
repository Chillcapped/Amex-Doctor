<cfcomponent extends="Controller">
	
	
	<cffunction name="create">
		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/portal_layouts/medications/compounds/create")>
	</cffunction>
	
	<cffunction name="info">
		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/portal_layouts/medications/compounds/info")>
	</cffunction>
	
	<cffunction name="index">
		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/portal_layouts/medications/compounds/index")>
	</cffunction>
	
	
	
</cfcomponent>