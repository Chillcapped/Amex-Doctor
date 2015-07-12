<cfcomponent>
	
	
	<cffunction name="index">
		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/portal_layouts/medications/ingredients/index")>
	</cffunction>
	
	
	<cffunction name="create">
		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/portal_layouts/medications/ingredients/create")>
	</cffunction>
	
	<cffunction name="info">
		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/portal_layouts/medications/ingredients/info")>
	</cffunction>
</cfcomponent>