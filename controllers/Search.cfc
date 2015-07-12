<cfcomponent extends="controller">
	
	<cffunction name="index">
		
		<cfset renderPage(hideDebugInformation="yes", template="/portal_layouts/#application.roles[session.user.role].name#/search/results")>
	</cffunction>
	
	
</cfcomponent>