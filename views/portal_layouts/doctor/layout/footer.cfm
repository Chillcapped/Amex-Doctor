<div id="dialog" style="display: none;"></div>


<script type="text/javascript" src="/bower_components/jquery/jquery.min.js"></script>
<script type="text/javascript" src="/bower_components/jquery-ui/jquery-ui.min.js"></script>
<script type="text/javascript" src="/javascripts/source/global/main.js"></script>
<script type="text/javascript" src="/javascripts/source/patients/patients.js"></script>
<script type="text/javascript" src="/javascripts/source/prescriptions/prescriptions.js"></script>
<cfoutput><script type="text/javascript" src="/javascripts/source/#lcase(application.roles[session.user.role].name)#/#lcase(application.roles[session.user.role].name)#.js"> </script></cfoutput>

<cfif structKeyExists(variables, "pageJS")>
<cfoutput>#pageJS#</cfoutput>
</cfif>

<cfif params.action EQ "authorize">

</cfif>
