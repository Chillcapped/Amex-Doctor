
<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/pageHeader")#</cfoutput>
<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/sideMenu")#</cfoutput>



<div id="contentContainer">

      <cfif !structKeyExists(params, "type")>
            <cfinclude template="avastin.cfm">
      <cfelse>
            <cfinclude template="avastinDex.cfm">
      </cfif>

</div>


<cfsavecontent variable="pageJS">
<script>

</script>

</cfsavecontent>
