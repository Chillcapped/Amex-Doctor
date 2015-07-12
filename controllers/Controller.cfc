<cfcomponent extends="Wheels">


	<!--- Force Login Block if User isnt logged in {Exception for urls in application.NoForceURL and controller wide in application.noForceControllers} --->
	<cfif !IsUserLoggedIn() and !listFind(application.noForceURLs, lcase(request.cgi.path_info))
		 and !listFind(application.noForceControllers, lcase(request.wheels.params.controller))>

		<!--- If token is in url validate it or send to login page --->
		<cfif structKeyExists(request.wheels.params, "authToken") and request.wheels.params.authToken NEQ "">
			<cfinvoke component="api.authorize" method="isValidToken" returnVariable="validToken">
				<cfinvokeargument name="token" value="#request.wheels.params.authToken#">
				<cfinvokeargument name="enc" value="false">
			</cfinvoke>
			<cfif validToken EQ "false">
				<cflocation url="/login" addToken="false">
			</cfif>
		<cfelse>
			<cflocation url="/login" addToken="false">
		</cfif>
	</cfif>

</cfcomponent>
