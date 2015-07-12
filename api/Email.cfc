<cfcomponent>

	<!--- Handles All Email Functions --->



	<!--- Send Invite Email --->
	<cffunction name="sendInviteEmail" access="public" hint="Emails an existing Invite Code to a Doctor">
		<cfargument name="inviteID" type="struct">

		<cfset result = structNew()>
		<cfset result.status = true>

		<!--- get Doctor Invite Info --->
		<cfquery name="getDoctorInfo" datasource="#application.contentDB#">
			select firstName, lastName, middleName, title, email, inviteCode, verifyString
			from doctors_invites
			where inviteID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.inviteID#">
			and redeemed = 0
		</cfquery>

		<!--- If Unverified, send it out --->
		<cfif getDoctorInfo.recordCount GT 0>
			<!--- Send Email With Link to Verify --->
			<cfmail subject="#application.appDisplayName#: You have been Invited!" to="andyj@materialflow.com" from="#application.email#">
				<cfoutput>
						<a href="#application.doctorInviteURL#?inviteCode=#getDoctorInfo.inviteCode#&verifyString=#getDoctorInfo.verifyString#">Click Here To Accept your Invite</a>
				</cfoutput>
			</cfmail>
			<cfset result.status = true>
			<cfset result.message = "Sent Verification Email to Doctor">
		<cfelse>
			<cfset result.status = false>
			<cfset result.message = "Doctor not found or is already verified">
		</cfif>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>


	<!--- Send Verification Email --->
	<cffunction name="sendDoctorVerificationEmail" access="public" hint="Sends a Doctors Verification Email">
		<cfargument name="doctorID" type="struct">
		<cfset result = structNew()>
		<cfset result.status = true>

		<!--- get Doctor Info --->
		<cfquery name="getDoctorInfo" datasource="#application.contentDB#">
			select firstName, lastName, middleName, title, email, verifyString, verified, authToken
			from doctors
			where doctorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.doctorID#">
			and verified = 0
		</cfquery>

		<!--- If Unverified, send it out --->
		<cfif getDoctorInfo.recordCount GT 0>
			<!--- Decrypt Auth Token ---->
			<cfinvoke component="miscellaneous.utils" method="dec" returnvariable="authToken">
				<cfinvokeargument name="info" value="#arguments.token#">
				<cfinvokeargument name="info2" value="#application.oversalt#">
			</cfinvoke>
			<!--- Send Email With Link to Verify --->
			<cfmail subject="Verify your Email Address" to="andyj@materialflow.com" from="#application.email#">
				<cfoutput>
						<a href="#application.doctorVerifyURL#?authToken=#authToken#&verifyString=#getDoctorInfo.verifyString#">Click Here</a>
				</cfoutput>
			</cfmail>
			<cfset result.status = true>
			<cfset result.message = "Sent Verification Email to Doctor">
		<cfelse>
			<cfset result.status = false>
			<cfset result.message = "Doctor not found or is already verified">
		</cfif>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>


	<!--- Send IP Authorize Email --->
	<cffunction name="sendIpApprovalRequest" access="public" hint="Sends email to user to authorize IP for login">
		<cfargument name="userInfo" type="struct" required="true">
		<cfargument name="requestToken" type="string" required="true">

		<!--- Hash Auth Token --->
		<cfinvoke component="miscellaneous.utils" method="computeHash" returnvariable="hashedToken">
			<cfinvokeargument name="password" value="#userInfo.authtoken#">
			<cfinvokeargument name="salt" value="#userInfo.userSalt#">
		</cfinvoke>

		<!--- Send Email With Link to Verify --->
		<cfmail subject="Amex Rx Portal - #cgi.remote_addr# IP is Requesting Access" to="andyj@materialflow.com" from="#application.email#" type="html">
			<h4>Unrecognized Login from IP: #cgi.remote_addr#</h4>
			<p>A Login request was made using your account credentials from IP address: #cgi.remote_addr#. We require email verification for any login attempt
			made from any IP address that is not recognized by our system. If you did not initiate this request, please change your password and contact us so we can investigate further.</p>
			<a href="http://#cgi.server_name#/unrecognized?authToken=#urlEncodedFormat(hashedtoken)#&requestToken=#urlEncodedFormat(arguments.requestToken)#&user=#urlEncodedFormat(arguments.userInfo.email)#">Click Here to Authorize This IP</a>
		</cfmail>

		<cfreturn true>
	</cffunction>

</cfcomponent>
