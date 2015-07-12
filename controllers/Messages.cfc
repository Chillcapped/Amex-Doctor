<cfcomponent extends="controller">


	<cffunction name="messages">
    <cfset renderPage( hideDebugInformation="yes", template="/portal_layouts/doctor/messages/messages")>
	</cffunction>

</cfcomponent>
