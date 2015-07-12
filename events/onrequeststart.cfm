<!--- Place code here that should be executed on the "onRequestStart" event. --->

<!--- If this is an Pharmacy Authorized IP, redirect to Amex Domain --->
<cfif structKeyExists(application.authorizedIPs.amexIPs, cgi.remote_addr)
and cgi.server_name EQ "rxportal.io">
      <cfif cgi.server_name NEQ "amex.rxportal.io">
            <cflocation url="http://amex.rxportal.io" addToken="false">
      </cfif>
</cfif>
<!--- If this is a doctor IP, redirect to MD domain --->
<cfif structKeyExists(application.authorizedIPs.doctorIPs, cgi.remote_addr)
and cgi.server_name EQ "rxportal.io">
      <cfif cgi.server_name NEQ "md.rxportal.io">
            <cflocation url="http://md.rxportal.io" addToken="false">
      </cfif>
</cfif>


<cfif cgi.server_name EQ "amex.rxportal.io">
      <cfif !structKeyExists(application.authorizedIps.amexIps, cgi.remote_addr)>

      </cfif>
</cfif>

<cfif cgi.server_name EQ "sales.rxportal.io">
      <cfif !structKeyExists(application.authorizedIps.amexIps, cgi.remote_addr)>

      </cfif>
</cfif>

<cfif cgi.server_name EQ "md.rxportal.io">
      <cfif !structKeyExists(application.authorizedIps.amexIps, cgi.remote_addr)>

      </cfif>
</cfif>
