<!--- Place HTML here that should be used as the default layout of your application --->
<!DOCTYPE HTML>
<html>
	<cfif structKeyExists(session, "user")>
		<cfinclude template="./portal_layouts/#lcase(application.roles[session.user.role].name)#/layout/meta.cfm"> 
	</cfif>
	<body>
		
		<cfif structKeyExists(session, "user")>
			<cfinclude template="./portal_layouts/#lcase(application.roles[session.user.role].name)#/layout/header.cfm"> 
		</cfif>

		<cfoutput>#includeContent()#</cfoutput>
		
		<cfif structKeyExists(session, "user")>
			<cfinclude template="./portal_layouts/#lcase(application.roles[session.user.role].name)#/layout/footer.cfm"> 
		</cfif>
	</body>
</html>
