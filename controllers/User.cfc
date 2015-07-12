<cfcomponent extends="controller">
	<cffunction name="loggedInUser">
			<cfset renderPage(layout="false", hideDebugInformation="yes")>
	</cffunction>

	<cffunction name="login">
		<cfparam name="params.username" default="">

		<cfif structKeyExists(params, "user") and !structKeyExists(params, "username")>
			<cfset params.username = params.user>
		</cfif>

		<!--- If we are attempting to login --->
		<cfif structKeyExists(params, "userName") and structKeyExists(params, "userpassword") and !isUserLoggedIn() and len(params.userPassword)>
			<cfinvoke component="api.authorize" method="loginUser" returnvariable="loginStatus">
				<cfinvokeargument name="username" value="#params.username#">
				<cfinvokeargument name="password" value="#params.userpassword#">
				<cfif structKeyExists(params, "authToken")>
					<cfinvokeargument name="authToken" value="#params.authToken#">
				</cfif>
				<cfif structKeyExists(params, "requestToken")>
					<cfinvokeargument name="requestToken" value="#params.requestToken#">
				</cfif>
			</cfinvoke>
		</cfif>
		<!--- If we are logged in, send this user to their homepage --->
		<cfif isUserLoggedIn()>
			<cflocation url="/home" addtoken="false">
		</cfif>
		<cfset renderPage(layout="false", hideDebugInformation="yes")>
	</cffunction>


	<cffunction name="logout">
		<cfif structKeyExists(application, "liveUsers")>
			<cfset APPLICATION.liveUsers[session.userID].status = "offline">
			<cfset APPLICATION.liveUsers[session.userID].LastLogOutTime = now()>
		</cfif>
		<cfif structKeyExists(session, "user")>
			<cfset structDelete(session, "user")>
		</cfif>
		<cflogout>
		<cflocation url="/login" addtoken="false">
		<cfset renderPage(layout="false", hideDebugInformation="yes")>
	</cffunction>


	<cffunction name="account">

		<cfset renderPage( hideDebugInformation="yes")>
	</cffunction>
	<cffunction name="help">

		<cfset renderPage( hideDebugInformation="yes")>
	</cffunction>
	<cffunction name="resetPassword">
		<cfparam name="status" default="">

		<!--- If we are on Step 1 of the Reset Process --->
		<cfif structKeyExists(form, "email") and !structKeyExists(params, "resetString")>
			<cfif isValid("email", params.email)>
				<cfinvoke component="api.users" method="sendResetPasswordEmail" returnVariable="emailStatus">
					<cfinvokeargument name="email" value="#params.email#">
					<cfinvokeargument name="returnType" value="struct">
				</cfinvoke>
			<cfelse>
				<cfset errors = arrayNew(1)>
				<cfset errors[1] = "Invalid Email Address">
			</cfif>

			<cfset status = "Sent">

		<!--- If User is from email reset url, validate the required reset  --->
		<cfelseif structKeyExists(params, "resetString") and structKeyExists(params, "authToken")>
			<cfset status = "Verify">
			<!---- If we have the password submitted,  store --->
			<cfif structKeyExists(form, "password1") and structKeyExists(form, "password2")>
				<cfif len(params.password1) GTE 6 and password1 EQ password2>
					<!--- Send New Password to Reset Pass --->
					<cfinvoke component="api.users" method="resetUserPassword" returnVariable="resetStatus">
						<cfinvokeargument name="email" value="#params.email#">
						<cfinvokeargument name="resetString" value="#params.resetString#">
						<cfinvokeargument name="authToken" value="#params.authToken#">
						<cfinvokeargument name="password" value="#params.password1#">
					</cfinvoke>


					<cfdump var="#resetStatus#">
					<cfabort>

				</cfif>
			</cfif>

		</cfif>
		<cfset renderPage(layout="false", hideDebugInformation="yes")>
	</cffunction>



	<cffunction name="messages">
			<cfset renderPage(hideDebugInformation="yes", template="/portal_layouts/#application.roles[session.user.role].name#/messages")>
	</cffunction>

	<cffunction name="shipments">


	</cffunction>


	<!--- Unrecognized IP --->
	<cffunction name="unrecognized">
		<cfif structKeyExists(params, "authToken") and structKeyExists(params, "requestToken") and structKeyExists(params, "user")>
			<cfinvoke component="api.authorize" method="validateIpRequestToken" returnVariable="validToken">
				<cfinvokeargument name="requestToken" value="#params.requestToken#">
				<cfinvokeargument name="user" value="#params.user#">
				<cfinvokeargument name="apiKey" value="#params.authToken#">
			</cfinvoke>
			<cfif validToken.status and structKeyExists(validToken, "addTo") and structKeyExists(application.authorizedIps, validToken.addTo)
			 and structKeyExists(application.authorizedIps[validToken.addedTo], request.cgi.remote_addr)>
				<cflocation url="/login?username=#params.user#">
			</cfif>
		</cfif>
		<cfset renderPage(hideDebugInformation="yes")>
	</cffunction>


	<cffunction name="home">



		<cfset renderPage(hideDebugInformation="yes")>
	</cffunction>

</cfcomponent>
