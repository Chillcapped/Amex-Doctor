<cfset fullViewRoles = "Admin,Tech,Pharmacist">
<cfset doctorViewRoles = "Doctor,Doctor-Delegate">


<!--- If we are Authorized to include full View --->
<cfif listFind(fullViewRoles, application.roles[session.user.role].name)>
	<cfinclude template="fullVersion.cfm">
<cfelse>
	<cfinclude template="doctorVersion.cfm">
</cfif>
