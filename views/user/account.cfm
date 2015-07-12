<cfif structKeyExists(session, "user")>
	<cfinclude template="../portal_layouts/#lcase(application.roles[session.user.role].name)#/account.cfm"> 
</cfif>