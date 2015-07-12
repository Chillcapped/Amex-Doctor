<div id="header">
	<img id="logo" src="/images/logo.jpg" height="90" width="150">
	<cfoutput>#includePartial("/portal_layouts/doctor/includes/searchContainer")#</cfoutput>

</div>
<!--- Template Shows Doctors Current Offices and Form to Add and Remove --->
<cfoutput>#includePartial("/portal_layouts/doctor/includes/sideMenu")#</cfoutput>

<div id="contentContainer">
	<cfif params.route EQ "offices">
		<cfinclude template="browse.cfm" />
	</cfif>
	<cfif params.route EQ "editOffice">
		<cfinclude template="edit.cfm" />
	</cfif>
	<cfif params.route EQ "addOffice">
		<cfinclude template="add.cfm" />
	</cfif>
</div>
